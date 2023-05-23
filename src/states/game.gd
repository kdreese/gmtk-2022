extends Node2D


var level: Level

var moves: int
var options_return_to_game: bool

@onready var speedrun_timer: Label = $"%SpeedrunTimer"


func _ready() -> void:
	var level_info: Dictionary = Global.LEVELS[Global.current_level_idx]
	level = load(level_info["path"]).instantiate() as Level
	var tile_map := level.get_node("TileMap") as TileMap

	add_child(level)
	var error := level.get_node("LevelEnd").connect("exit_reached_success", Callable(self, "_on_LevelEnd_exit_reached_success"))
	assert(not error)

	$CanvasLayer/UI/V/LevelName.text = level_info["name"]
	if "text" in level_info:
		$CanvasLayer/UI/Textbox/MessageText.text = level_info["text"]
		$CanvasLayer/UI/Textbox.show()

	for coords in tile_map.get_used_cells(0):
		var tile_source_id := tile_map.get_cell_source_id(0, coords)
		var source := tile_map.tile_set.get_source(tile_source_id)
		var tile_name := source.resource_name
		if tile_name == "Start":
			var player := preload("res://src/objects/player.tscn").instantiate() as Node2D
			error = player.connect("player_moved", Callable(self, "_on_player_move"))
			assert(not error)
			error = player.connect("should_update_z_index", Callable(self, "_on_player_should_update_z_index"))
			assert(not error)
			player.position = tile_map.map_to_local(coords)
			player.grid_coords = coords
			player.tile_map = tile_map
			level.add_child(player)

	reset_move_counter()
	var best_score = Global.best_scores[Global.current_level_idx]
	if best_score != -1:
		$"%BestMove".text = "Best: %d" % best_score
		if best_score == Global.LEVELS[Global.current_level_idx]["perfect_score"]:
			$"%Star".show()
		else:
			$"%Star".hide()
	else:
		$CanvasLayer/UI/V/H.hide()

	update_timer()
	error = Autosplitter.connect("timer_updated", Callable(self, "update_timer"))
	assert(not error)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		get_tree().paused = true
		hide_ui()
		$CanvasLayer/PauseMenu.show()
		$CanvasLayer/PauseMenu/C/V/Buttons/ResumeButton.grab_focus()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("restart"):
		restart()
		get_viewport().set_input_as_handled()


func update_move_counter() -> void:
	$CanvasLayer/UI/V/MoveCounter.text = "Moves: %d" % moves


func reset_move_counter() -> void:
	moves = 0
	update_move_counter()


func update_timer(final_time := false) -> void:
	var should_show_timer := Autosplitter.speedrun_is_running and Global.speedrun_timer_enabled
	if not should_show_timer == speedrun_timer.visible:
		speedrun_timer.visible = should_show_timer

	var minutes := floor(Autosplitter.speedrun_time / 60.0) as int
	var non_minutes := fmod(Autosplitter.speedrun_time, 60.0)
	var seconds := floor(non_minutes) as int
	var non_seconds := fmod(non_minutes, 1.0)
	var milliseconds := floor(non_seconds * 1000) as int

	var time_str = "%02d.%03d" % [seconds, milliseconds]
	if minutes > 0:
		time_str = "%d:%s" % [minutes, time_str]
	if final_time:
		time_str = "%s Final Time" % time_str

	speedrun_timer.text = time_str


func _on_player_move() -> void:
	moves += 1
	update_move_counter()


func _on_player_should_update_z_index(grid_coords: Vector2) -> void:
	level.handle_player_move(grid_coords)


func hide_ui():
	$CanvasLayer/UI.hide()
	for element in get_tree().get_nodes_in_group("UI Elements"):
		element.hide()


func show_ui():
	$CanvasLayer/UI.show()
	for element in get_tree().get_nodes_in_group("UI Elements"):
		element.show()


func _on_LevelEnd_exit_reached_success():
	get_tree().paused = true
	Autosplitter.run_split()
	$CanvasLayer/LevelComplete.update_text(moves)
	$CanvasLayer/LevelComplete.show()
	Global.update_best_scores(moves)
	hide_ui()


func _on_OptionsMenu_options_exited() -> void:
	var player := level.get_node_or_null("Player")
	if player:
		player.update_animation_speed()
	for gate in get_tree().get_nodes_in_group("Gates"):
		gate.update_animation_speed()
	if options_return_to_game:
		# We came from the game scene, so un-pause the game.
		get_tree().paused = false
		show_ui()
	else:
		$CanvasLayer/PauseMenu.show()
		$CanvasLayer/PauseMenu/C/V/Buttons/OptionsButton.grab_focus()


func _on_MenuButton_pressed() -> void:
	Autosplitter.run_reset()
	var error := get_tree().change_scene_to_file("res://src/states/menu.tscn")
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


func restart() -> void:
	var error := get_tree().reload_current_scene()
	assert(not error)
