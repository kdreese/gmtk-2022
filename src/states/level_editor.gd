extends Node2D


const BUTTON_IGNORE_BOX = Rect2(0, 0, 200, 100)

enum {
	NOTHING,
	NORMAL_TILE,
	START_TILE,
	FINISH_PAD
}

## The object that we are placing
var object_to_place: int = NORMAL_TILE

## The level we are currently editing
var level: Level = null

## The tile currently underneath the cursor.
var mouseover_tile: Vector2i = Vector2i(0,0)

## The object we are placing, if not a tile.
var current_object: Node2D = null

## The position offset from tile center of the current object.
var current_object_offset: Vector2 = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level = preload("res://src/levels/level.tscn").instantiate() as Level
	add_child(level)


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


func mouse_entered_tile(current: Vector2i, prev: Vector2i) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		place_object(current)
	else:
		preview_object(current)


func preview_object(coords: Vector2i)-> void:
	level.tile_map.clear_layer(1)
	if object_to_place == NOTHING:
		free_current_object()
	elif object_to_place == NORMAL_TILE:
		level.place_tile(coords, 1)
	elif object_to_place == START_TILE:
		level.place_tile(coords, 1)
		level.tile_map.set_cell(1, coords, 1, Vector2i(0, 0))
	elif object_to_place == FINISH_PAD:
		current_object.position = level.tile_map.map_to_local(coords) + current_object_offset


func place_object(coords: Vector2i) -> void:
	if object_to_place == NORMAL_TILE:
		level.place_tile(coords)
	elif object_to_place == START_TILE:
		level.place_tile(coords)
		level.tile_map.set_cell(0, coords, 1, Vector2i(0, 0))
	elif object_to_place == FINISH_PAD:
		current_object.position = level.tile_map.map_to_local(coords) + current_object_offset
		current_object.modulate = Color.WHITE
		current_object = preload("res://src/objects/level_end.tscn").instantiate() as LevelEnd
		current_object.modulate = Color(1.0, 1.0, 1.0, 0.75)
		level.objects.add_child(current_object)


func free_current_object():
	if current_object:
		level.objects.remove_child(current_object)
		current_object.queue_free()
		current_object = null


func button_selected(idx: int) -> void:
	free_current_object()

	object_to_place = idx
	if object_to_place == FINISH_PAD:
		current_object = preload("res://src/objects/level_end.tscn").instantiate() as LevelEnd
		current_object_offset = Vector2(0, -16)
		current_object.modulate = Color(1.0, 1.0, 1.0, 0.75)
		level.objects.add_child(current_object)

func play_level() -> void:
	free_current_object()
	var data := level.save_level_data()
	var game := preload("res://src/states/game.tscn").instantiate() as Game
	get_tree().get_root().add_child(game)
	get_tree().set_current_scene(game)
	get_tree().get_root().remove_child(self)
	game.play_level_from_string(Utils.b64_encode(data))


func show_options() -> void:
	get_tree().paused = true
	%OptionsMenu.show_menu()


func options_exited() -> void:
	get_tree().paused = false


func go_to_menu() -> void:
	get_tree().change_scene_to_file("res://src/states/menu.tscn")
