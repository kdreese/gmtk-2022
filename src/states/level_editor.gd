extends Control


const BUTTON_IGNORE_BOX := Rect2(0, 0, 200, 100)
const OBJECT_PREVIEW_MODULATE := Color(1.0, 1.0, 1.0, 0.35)
const LEVEL_BOUNDING_BOX := Rect2(0, 80, 640, 280)
const WIRE_DOT_SOURCE_ID := 16


enum {
	NOTHING = 0,
	ERASE,
	NORMAL_TILE,
	START_TILE,
	FINISH_PAD,
	WIRES,
	BUTTON,
	TOGGLE,
	GATE,
}

## The object that we are placing
var object_to_place: int = NOTHING

## The level we are currently editing
var level: Level = null

## The ground tiles for the level we're editing
var ground_tile_map: TileMapLayer = null
## The preview layer for ground tiles
var ground_preview_tile_map: TileMapLayer = null
## The wire tile map for the level we're editing
var wire_tile_map: TileMapLayer = null
## The preview layer for wires
var wire_preview_tile_map: TileMapLayer = null


## The tile currently underneath the cursor.
var mouseover_tile: Vector2i = Vector2i(0,0)

## The object we are placing, if not a tile.
var current_object: LevelObject = null
## The position offset from tile center of the current object.
var current_object_offset: Vector2 = Vector2(0, 0)

var tile_button_group: ButtonGroup

@onready var weight_editor: WeightEditor = %WeightEditor

var save_data_temp: PackedByteArray = []



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level = preload("res://src/levels/level.tscn").instantiate() as Level
	add_child(level)

	if Global.level_to_load:
		level.load_level_data(Global.level_to_load)

	ground_tile_map = level.ground_tile_map
	ground_preview_tile_map = level.ground_preview_tile_map
	wire_tile_map = level.wire_tile_map
	wire_preview_tile_map = level.wire_preview_tile_map

	tile_button_group = ButtonGroup.new()
	tile_button_group.allow_unpress = true

	for button in %TileSelector/S/M/H.get_children() as Array[TileSelectButton]:
		button.button_group = tile_button_group

	if level.level_name:
		%LevelName.text = level.level_name
	else:
		level.level_name = "Untitled"

	%NameEditor.name_chosen.connect(name_editor_closed)
	%LoadCodeMenu.load_level.connect(load_level_from_code)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_pos := get_local_mouse_position()
		if not LEVEL_BOUNDING_BOX.has_point(mouse_pos):
			ground_preview_tile_map.clear()
			wire_preview_tile_map.clear()
			return
		var grid_coords = ground_tile_map.local_to_map(mouse_pos)
		if grid_coords != mouseover_tile:
			mouse_entered_tile(grid_coords, mouseover_tile)
			mouseover_tile = grid_coords

	elif event is InputEventMouseButton:
		var mouse_pos := get_local_mouse_position()
		if not LEVEL_BOUNDING_BOX.has_point(mouse_pos):
			ground_preview_tile_map.clear()
			wire_preview_tile_map.clear()
			return
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if object_to_place == NOTHING and not %WeightEditor.visible:
				var object = get_object_at_location(mouseover_tile)
				if object != null:
					current_object = object
					show_weight_menu(mouseover_tile)
			else:
				place_object(mouseover_tile)


func mouse_entered_tile(current: Vector2i, prev: Vector2i) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if object_to_place == WIRES:
			level.place_wire(prev, current)
		else:
			# If the mouse button is down when we enter the tile, treat it as a click.
			place_object(current)
	else:
		preview_object(current)


## Return the object at the specified grid position, or null if there is no object there.
func get_object_at_location(coords: Vector2i) -> LevelObject:
	for object in level.objects.get_children() as Array[LevelObject]:
		if coords == object.get_grid_position(ground_tile_map):
			return object

	return null


func show_weight_menu(coords: Vector2i) -> void:
	# Set the mouse button as handled, so it doesn't close the menu.
	get_viewport().set_input_as_handled()

	if current_object.get_object_type() == LevelObject.GATE:
		# Gates have no weight.
		return

	if current_object.minimum_weight == 1 and current_object.maximum_weight == 6:
		weight_editor.set_selected(0)
	else:
		weight_editor.set_selected(current_object.maximum_weight)

	weight_editor.position = ground_tile_map.map_to_local(coords)
	var bbox = LEVEL_BOUNDING_BOX
	bbox.position -= weight_editor.position
	weight_editor.set_bounding_box(bbox)
	weight_editor.show()


func preview_object(coords: Vector2i)-> void:
	if object_to_place == ERASE:
		preview_erase(coords)
	elif object_to_place == NORMAL_TILE:
		ground_preview_tile_map.clear()
		level.place_tile(coords, true)
	elif object_to_place == START_TILE:
		ground_preview_tile_map.clear()
		level.place_tile(coords, true, true)
	elif object_to_place in [FINISH_PAD, BUTTON, TOGGLE, GATE]:
		if ground_tile_map.get_cell_source_id(coords) == 0 and not get_object_at_location(coords):
			current_object.modulate = OBJECT_PREVIEW_MODULATE
			current_object.position = ground_tile_map.map_to_local(coords) + current_object.get_position_offset()
		else:
			current_object.modulate = Color.TRANSPARENT
			current_object.position = Vector2(-20, -20)
	elif object_to_place == WIRES:
		wire_preview_tile_map.clear()
		if wire_tile_map.get_cell_source_id(coords) == -1:
			wire_preview_tile_map.set_cell(coords, WIRE_DOT_SOURCE_ID, Vector2i(0, 0))


func place_object(coords: Vector2i) -> void:
	if object_to_place == ERASE:
		erase(coords)
	elif object_to_place == NORMAL_TILE:
		level.place_tile(coords)
		ground_preview_tile_map.clear()
	elif object_to_place == START_TILE:
		level.place_tile(coords, false, true)
		ground_preview_tile_map.clear()
		tile_button_group.get_pressed_button().button_pressed = false
	elif object_to_place in [FINISH_PAD, BUTTON, TOGGLE, GATE]:
		if ground_tile_map.get_cell_source_id(coords) == 0 and get_object_at_location(coords) == current_object:
			current_object.position = ground_tile_map.map_to_local(coords) + current_object.get_position_offset()
			current_object.modulate = Color.WHITE
			current_object = null
			tile_button_group.get_pressed_button().button_pressed = false
			# TODO: placing gates needs to be done back to front or else the display is screwed up.
	elif object_to_place == WIRES:
		wire_preview_tile_map.clear()
		if wire_tile_map.get_cell_source_id(coords) == -1:
			wire_tile_map.set_cell(coords, WIRE_DOT_SOURCE_ID, Vector2i(0, 0))



## Preview erasing whatever is on the tile beneath the cursor.
func preview_erase(coords: Vector2i) -> void:
	if current_object != null:
		# We were previewing an erase somewhere else. Reset that modulate.
		current_object.modulate = Color.WHITE

	current_object = null

	for source_id in [0, 1]:
		# Get all the tiles that were being previewed as erased, and re-add them to the level. This
		# should only ever be 1 tile.
		var tiles := ground_preview_tile_map.get_used_cells_by_id(source_id, Vector2(0,0))
		for tile in tiles:
			level.place_tile(tile, false, bool(source_id == 1))

	# Un-preview-erase any existing wires.
	for tile in wire_preview_tile_map.get_used_cells():
		var wire_source_id := wire_preview_tile_map.get_cell_source_id(tile)
		var alternative_tile := wire_preview_tile_map.get_cell_alternative_tile(tile)
		wire_tile_map.set_cell(tile, wire_source_id, Vector2i(0, 0), alternative_tile)

	ground_preview_tile_map.clear()
	wire_preview_tile_map.clear()

	# Check to see if there is an object on the tile we're on.
	var object = get_object_at_location(coords)
	if object != null:
		current_object = object
		current_object.modulate = OBJECT_PREVIEW_MODULATE
		return

	# If there is a wire, preview erase that.
	if wire_tile_map.get_cell_source_id(coords) != -1:
		var wire_source_id := wire_tile_map.get_cell_source_id(coords)
		var alternative_tile := wire_tile_map.get_cell_alternative_tile(coords)
		wire_preview_tile_map.set_cell(coords, wire_source_id, Vector2i(0, 0), alternative_tile)
		wire_tile_map.set_cell(coords, -1)
		return

	var source_id = ground_tile_map.get_cell_source_id(coords)
	if source_id in [0, 1]:
		level.remove_tile(coords)
		level.place_tile(coords, true, bool(source_id == 1))


func erase(coords: Vector2i) -> void:
	if current_object != null:
		# We're selecting an object. Erase it.
		# TODO: replace ground under closed gate tiles.
		level.objects.remove_child(current_object)
		current_object.queue_free()
		current_object = null
		return

	# If there is a wire, erase that.
	if wire_tile_map.get_cell_source_id(coords) != -1 or wire_preview_tile_map.get_cell_source_id(coords) != -1:
		wire_tile_map.set_cell(coords, -1)
		wire_preview_tile_map.clear()
		return

	level.remove_tile(coords)
	ground_preview_tile_map.clear()


## Delete whatever is stored in current_object.
func free_current_object():
	if current_object:
		print("Freeing object ", current_object)
		level.objects.remove_child(current_object)
		current_object.queue_free()
		current_object = null


func button_toggled(toggled_on: bool, idx: int) -> void:
	ground_preview_tile_map.clear()
	free_current_object()

	if toggled_on:
		object_to_place = idx
		if object_to_place == FINISH_PAD:
			current_object = preload("res://src/objects/level_end.tscn").instantiate() as LevelEnd
		elif object_to_place == BUTTON:
			current_object = preload("res://src/objects/level_button.tscn").instantiate() as LevelButton
		elif object_to_place == TOGGLE:
			current_object = preload("res://src/objects/toggle.tscn").instantiate() as Toggle
		elif object_to_place == GATE:
			current_object = preload("res://src/objects/gate.tscn").instantiate() as Gate
			current_object.is_open = false
			current_object.tile_map = ground_tile_map

		if current_object != null:
			current_object.modulate = Color.TRANSPARENT
			level.objects.add_child(current_object)
	else:
		object_to_place = NOTHING


func weight_changed(new_weight: int) -> void:
	if current_object == null or current_object.get_object_type() == LevelObject.GATE:
		return

	if new_weight == 0:
		current_object.minimum_weight = 1
		current_object.maximum_weight = 6
	else:
		current_object.minimum_weight = new_weight
		current_object.maximum_weight = new_weight

	current_object.update_weight_display()


func weight_editor_exited() -> void:
	# Set the current object to null to show that we're done editing it.
	current_object = null


func show_name_editor() -> void:
	level.wire_preview_tile_map.clear()
	level.ground_preview_tile_map.clear()
	free_current_object()
	if tile_button_group.get_pressed_button():
		tile_button_group.get_pressed_button().button_pressed = false
	object_to_place = NOTHING
	%NameEditor.open_window(%LevelName.text)


func name_editor_closed(new_name: String) -> void:
	if new_name != null:
		level.level_name = new_name
		%LevelName.text = new_name


func play_level() -> void:
	free_current_object()
	var result := level.save_level_data()
	if not result[0]:
		%PopupPanel.dialog_text = result[1]
		%PopupPanel.popup_centered()
		return
	var game := preload("res://src/states/game.tscn").instantiate() as Game
	# This is a fake change_scene_to_file so that we can call play_level_from_string after the scene
	# is changed.
	get_tree().get_root().add_child(game)
	get_tree().set_current_scene(game)
	get_tree().get_root().remove_child(self)
	game.play_level_from_editor(Utils.b64_encode(result[1]))


func show_save_menu() -> void:
	var result = level.save_level_data()
	if not result[0]:
		%PopupPanel.dialog_text = result[1]
		%PopupPanel.popup_centered()
		return

	save_data_temp = result[1]

	%SaveFileDialog.current_dir = "user://levels"

	var line_edit: LineEdit = %SaveFileDialog.get_line_edit()
	line_edit.text = %LevelName.text.to_lower().replace(" ", "_") + ".lvl"
	line_edit.select(0, -4)

	%FileDialogBackground.show()
	%SaveFileDialog.popup_centered()


func save_level() -> void:
	var path = %SaveFileDialog.get_current_path()

	print("Saving file to ", path)
	var fp = FileAccess.open(path, FileAccess.WRITE)
	if fp == null:
		push_error("Could not open file.")
		return

	fp.store_buffer(save_data_temp)
	fp.close()

	%FileDialogBackground.hide()


func show_load_menu() -> void:
	%LoadFileDialog.current_dir = "user://levels"
	%FileDialogBackground.show()
	%LoadFileDialog.popup_centered()


func load_level() -> void:
	var path = %LoadFileDialog.get_current_path()

	print("Loading data from ", path)

	var data = FileAccess.get_file_as_bytes(path)
	if not data:
		print(FileAccess.get_open_error())
		push_error("Could not open file.")
		return

	# TODO: error checking here.
	level.load_level_data(data)
	%LevelName.text = level.level_name

	%FileDialogBackground.hide()


func cancel_save_load() -> void:
	%FileDialogBackground.hide()


func show_save_code_menu() -> void:
	var result = level.save_level_data()
	if not result[0]:
		%PopupPanel.dialog_text = result[1]
		%PopupPanel.popup_centered()
		return

	var code = Utils.b64_encode(result[1])

	%SaveCodeMenu.show_menu(code)


func show_load_code_menu() -> void:
	%LoadCodeMenu.show_menu()


func load_level_from_code(code: String) -> void:
	var data = Utils.b64_decode(code)

	level.load_level_data(data)
	%LevelName.text = level.level_name


func show_options() -> void:
	get_tree().paused = true
	%OptionsMenu.show_menu()


func options_exited() -> void:
	get_tree().paused = false


func go_to_menu() -> void:
	get_tree().change_scene_to_file("res://src/states/menu.tscn")
