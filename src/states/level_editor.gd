extends Node2D


const BUTTON_IGNORE_BOX := Rect2(0, 0, 200, 100)
const OBJECT_PREVIEW_MODULATE := Color(1.0, 1.0, 1.0, 0.75)

enum {
	NOTHING = 0,
	ERASE,
	NORMAL_TILE,
	START_TILE,
	FINISH_PAD
}

## The object that we are placing
var object_to_place: int = NOTHING

## The level we are currently editing
var level: Level = null

## The tile currently underneath the cursor.
var mouseover_tile: Vector2i = Vector2i(0,0)

## The object we are placing, if not a tile.
var current_object: LevelObject = null
## The position offset from tile center of the current object.
var current_object_offset: Vector2 = Vector2(0, 0)

var tile_button_group: ButtonGroup

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level = preload("res://src/levels/level.tscn").instantiate() as Level
	add_child(level)

	tile_button_group = ButtonGroup.new()
	tile_button_group.allow_unpress = true

	for button in %TileSelector/S/H.get_children() as Array[TileSelectButton]:
		button.button_group = tile_button_group


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_pos := get_local_mouse_position()
		if BUTTON_IGNORE_BOX.has_point(mouse_pos) or %TileSelector.get_rect().has_point(mouse_pos):
			level.tile_map.clear_layer(1)
			return
		var grid_coords = level.tile_map.local_to_map(mouse_pos)
		if grid_coords != mouseover_tile:
			mouse_entered_tile(grid_coords, mouseover_tile)
			mouseover_tile = grid_coords

	elif event is InputEventMouseButton:
		var mouse_pos := get_local_mouse_position()
		if BUTTON_IGNORE_BOX.has_point(mouse_pos) or %TileSelector.get_rect().has_point(mouse_pos):
			level.tile_map.clear_layer(1)
			return
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			place_object(mouseover_tile)


func mouse_entered_tile(current: Vector2i, _prev: Vector2i) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		place_object(current)
	else:
		preview_object(current)


func preview_object(coords: Vector2i)-> void:
	if object_to_place == ERASE:
		preview_erase(coords)
	elif object_to_place == NORMAL_TILE:
		level.tile_map.clear_layer(1)
		level.place_tile(coords, 1)
	elif object_to_place == START_TILE:
		level.tile_map.clear_layer(1)
		level.place_tile(coords, 1)
		level.tile_map.set_cell(1, coords, 1, Vector2i(0, 0))
	elif object_to_place == FINISH_PAD:
		if level.tile_map.get_cell_source_id(0, coords) == 0:
			current_object.modulate = OBJECT_PREVIEW_MODULATE
			current_object.position = level.tile_map.map_to_local(coords) + current_object.get_position_offset()
		else:
			current_object.modulate = Color.TRANSPARENT


func place_object(coords: Vector2i) -> void:
	if object_to_place == ERASE:
		erase(coords)
	elif object_to_place == NORMAL_TILE:
		level.place_tile(coords)
		level.tile_map.clear_layer(1)
	elif object_to_place == START_TILE:
		level.place_tile(coords)
		level.tile_map.set_cell(0, coords, 1, Vector2i(0, 0))
		level.tile_map.clear_layer(1)
		tile_button_group.get_pressed_button().button_pressed = false
	elif object_to_place == FINISH_PAD:
		if level.tile_map.get_cell_source_id(0, coords) == 0:
			current_object.position = level.tile_map.map_to_local(coords) + current_object.get_position_offset()
			current_object.modulate = Color.WHITE
			current_object = null
			tile_button_group.get_pressed_button().button_pressed = false


func preview_erase(coords: Vector2i) -> void:
	if current_object != null:
		# We were previewing an erase somewhere else. Reset that modulate.
		current_object.modulate = Color.WHITE

	current_object = null

	for source_id in [0, 1]:
		var tiles := level.tile_map.get_used_cells_by_id(1, source_id, Vector2(0,0))
		for tile in tiles:
			level.place_tile(tile, 0)
			if source_id == 1:
				level.tile_map.set_cell(0, tile, source_id, Vector2i(0, 0))
	level.tile_map.clear_layer(1)

	# Check to see if there is an object on the tile we're on.
	for object in level.objects.get_children() as Array[LevelObject]:
		if level.tile_map.local_to_map(object.position - object.get_position_offset()) == coords:
			current_object = object
			current_object.modulate = OBJECT_PREVIEW_MODULATE
			return

	var source_id = level.tile_map.get_cell_source_id(0, coords)
	if source_id in [0, 1]:
		level.remove_tile(coords)
		level.place_tile(coords, 1)
		if source_id == 1:
			level.tile_map.set_cell(1, coords, source_id, Vector2i(0, 0))


func erase(coords: Vector2i) -> void:
	if current_object != null:
		# We shoudl erase this object.
		level.objects.remove_child(current_object)
		current_object.queue_free()
		current_object = null
		return

	level.remove_tile(coords)
	level.tile_map.clear_layer(1)


func free_current_object():
	if current_object:
		level.objects.remove_child(current_object)
		current_object.queue_free()
		current_object = null


func button_toggled(toggled_on: bool, idx: int) -> void:
	level.tile_map.clear_layer(1)
	free_current_object()

	if toggled_on:
		object_to_place = idx
		if object_to_place == FINISH_PAD:
			current_object = preload("res://src/objects/level_end.tscn").instantiate() as LevelEnd
			current_object.modulate = Color.TRANSPARENT
			level.objects.add_child(current_object)
	else:
		object_to_place = NOTHING


func play_level() -> void:
	free_current_object()
	var result := level.save_level_data()
	if not result[0]:
		%PopupPanel.dialog_text = result[1]
		%PopupPanel.popup_centered()
		return
	var game := preload("res://src/states/game.tscn").instantiate() as Game
	get_tree().get_root().add_child(game)
	get_tree().set_current_scene(game)
	get_tree().get_root().remove_child(self)
	game.play_level_from_string(Utils.b64_encode(result[1]))


func show_options() -> void:
	get_tree().paused = true
	%OptionsMenu.show_menu()


func options_exited() -> void:
	get_tree().paused = false


func go_to_menu() -> void:
	get_tree().change_scene_to_file("res://src/states/menu.tscn")
