extends Node2D


var level: Level

var moves: int


func _ready() -> void:
	level = load(Global.level_path).instance() as Level
	var tile_map := level.get_node("TileMap") as TileMap

	add_child(level)
	var error := level.get_node("LevelEnd").connect("exit_reached_success", self, "_on_LevelEnd_exit_reached_success")
	assert(not error)

	for coords in tile_map.get_used_cells():
		var tile := tile_map.get_cell(coords.x, coords.y)
		if tile_map.tile_set.tile_get_name(tile) == "Start":
			var player := preload("res://src/objects/Player.tscn").instance() as Node2D
			error = player.connect("player_moved", self, "_on_player_move")
			assert(not error)
			player.position = tile_map.map_to_world(coords)
			player.grid_coords = coords
			player.tile_map = tile_map
			level.add_child(player)

	reset_move_counter()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		get_tree().paused = true
		$PauseMenu/ColorRect.show()
		$PauseMenu/ColorRect/C/V/Buttons/ResumeButton.grab_focus()
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("restart"):
		var error := get_tree().reload_current_scene()
		assert(not error)
		get_tree().set_input_as_handled()


func update_move_counter() -> void:
	$UI/MoveCounter.text = "Moves: %d" % moves


func reset_move_counter() -> void:
	moves = 0
	update_move_counter()


func _on_player_move():
	moves += 1
	update_move_counter()
	level.handle_player_move()


func _on_LevelEnd_exit_reached_success(next_level_path: String):
	get_tree().paused = true
	$LevelComplete.update(next_level_path)
	$LevelComplete/ColorRect.show()


func _on_OptionsButton_pressed() -> void:
	$PauseMenu/ColorRect.hide()
	$OptionsMenu/ColorRect.show()
	$OptionsMenu/ColorRect/C/V/BackButton.grab_focus()


func _on_OptionsMenu_options_exited() -> void:
	level.get_node("Player").update_animation_speed()
	$PauseMenu/ColorRect.show()
	$PauseMenu/ColorRect/C/V/Buttons/OptionsButton.grab_focus()
