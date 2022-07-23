extends Node2D


var level: Level

var moves: int
var options_return_to_game: bool


func _ready() -> void:
	level = load(Global.level_path).instance() as Level
	var tile_map := level.get_node("TileMap") as TileMap

	add_child(level)
	var error := level.get_node("LevelEnd").connect("exit_reached_success", self, "_on_LevelEnd_exit_reached_success")
	assert(not error)

	$CanvasLayer/UI/V/LevelName.text = level.get_node("LevelEnd").level_name
	var level_text = level.get_node("LevelEnd").level_text
	$CanvasLayer/UI/Textbox/MessageText.text = level_text
	if level_text != "":
		$CanvasLayer/UI/Textbox.show()

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
		hide_ui()
		$CanvasLayer/PauseMenu.show()
		$CanvasLayer/PauseMenu/C/V/Buttons/ResumeButton.grab_focus()
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("restart"):
		var error := get_tree().reload_current_scene()
		assert(not error)
		get_tree().set_input_as_handled()


func update_move_counter() -> void:
	$CanvasLayer/UI/V/MoveCounter.text = "Moves: %d" % moves


func reset_move_counter() -> void:
	moves = 0
	update_move_counter()


func _on_player_move(grid_coords: Vector2):
	moves += 1
	update_move_counter()
	level.handle_player_move(grid_coords)


func hide_ui():
	$CanvasLayer/UI.hide()
	for element in get_tree().get_nodes_in_group("UI Elements"):
		element.hide()


func show_ui():
	$CanvasLayer/UI.show()
	for element in get_tree().get_nodes_in_group("UI Elements"):
		element.show()


func _on_LevelEnd_exit_reached_success(next_level_path: String):
	get_tree().paused = true
	$CanvasLayer/LevelComplete.update_text(next_level_path)
	$CanvasLayer/LevelComplete.show()
	hide_ui()


func _on_OptionsMenu_options_exited() -> void:
	level.get_node("Player").update_animation_speed()
	if options_return_to_game:
		# We came from the game scene, so un-pause the game.
		get_tree().paused = false
		show_ui()
	else:
		$CanvasLayer/PauseMenu.show()
		$CanvasLayer/PauseMenu/C/V/Buttons/OptionsButton.grab_focus()


func _on_MenuButton_pressed() -> void:
	# Go back to the main menu.
	var error := get_tree().change_scene("res://src/states/Menu.tscn")
	assert(not error)


func _on_OptionsButton_pressed() -> void:
	get_tree().paused = true
	options_return_to_game = true
	hide_ui()
	$CanvasLayer/OptionsMenu.show_menu()


func _on_PauseMenu_OptionsButton_pressed() -> void:
	options_return_to_game = false
	$CanvasLayer/PauseMenu.hide()
	$CanvasLayer/OptionsMenu.show_menu()


func _on_RestartButton_pressed() -> void:
	var error := get_tree().reload_current_scene()
	assert(not error)
