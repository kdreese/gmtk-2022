extends Node2D


var level: Level

var moves: int
var options_return_to_game: bool

onready var speedrun_timer: Label = $"%SpeedrunTimer"


func _ready() -> void:
	var level_info: Dictionary = Global.LEVELS[Global.current_level_idx]
	level = load(level_info["path"]).instance() as Level
	var tile_map := level.get_node("TileMap") as TileMap

	add_child(level)

	# Put objects in the a YSort node
	var y_sort := YSort.new()
	y_sort.name = "YSort"
	for object in get_tree().get_nodes_in_group("YSortObjects"):
		var node := object as Node2D
		node.get_parent().remove_child(node)
		y_sort.add_child(node)
	level.add_child(y_sort)

	for level_end in get_tree().get_nodes_in_group("LevelEnds"):
		var error := (level_end as Node2D).connect("exit_reached_success", self, "_on_LevelEnd_exit_reached_success")
		assert(not error)

	$CanvasLayer/UI/V/LevelName.text = level_info["name"]
	if "text" in level_info:
		$CanvasLayer/UI/Textbox/MessageText.text = level_info["text"]
		$CanvasLayer/UI/Textbox.show()

	for coords in tile_map.get_used_cells():
		var tile := tile_map.get_cell(coords.x, coords.y)
		if tile_map.tile_set.tile_get_name(tile) == "Start":
			var player := preload("res://src/objects/Player.tscn").instance() as Node2D
			var error := player.connect("player_moved", self, "_on_player_move")
			assert(not error)
			player.position = tile_map.map_to_world(coords)
			player.grid_coords = coords
			player.tile_map = tile_map
			y_sort.add_child(player)

	reset_move_counter()

	update_timer()
	var error := Autosplitter.connect("timer_updated", self, "update_timer")
	assert(not error)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		get_tree().paused = true
		hide_ui()
		$CanvasLayer/PauseMenu.show()
		$CanvasLayer/PauseMenu/C/V/Buttons/ResumeButton.grab_focus()
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("restart"):
		restart()
		get_tree().set_input_as_handled()


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


func _on_player_move():
	moves += 1
	update_move_counter()


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
	for player in get_tree().get_nodes_in_group("Players"):
		player.update_animation_speed()
	if options_return_to_game:
		# We came from the game scene, so un-pause the game.
		get_tree().paused = false
		show_ui()
	else:
		$CanvasLayer/PauseMenu.show()
		$CanvasLayer/PauseMenu/C/V/Buttons/OptionsButton.grab_focus()


func _on_MenuButton_pressed() -> void:
	Autosplitter.run_reset()
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


func restart() -> void:
	var error := get_tree().reload_current_scene()
	assert(not error)
