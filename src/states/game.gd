class_name Game
extends Node2D


const START_TILE_SOURCE_ID := 1


@onready var speedrun_timer: Label = %SpeedrunTimer
@onready var best_move: Label = %BestMove
@onready var star: TextureRect = %Star


var single_level: bool = false
var level: Level
var player: Player

var moves: int
var options_return_to_game: bool


func play_campaign():
	single_level = false
	Global.current_level_idx = 0
	load_level(Global.LEVELS[0])
	show_best_score()
	Autosplitter.timer_updated.connect(self.update_timer)


func play_single_level(level_idx: int):
	single_level = true
	Global.current_level_idx = level_idx
	load_level(Global.LEVELS[level_idx])
	show_best_score()


func play_level_from_string(data: String):
	single_level = true
	Global.current_level_idx = -1
	load_level_from_string(data)


## Load a level from its exported data as a b64 encoded string.
func load_level_from_string(data: String):
	if level != null:
		remove_child(level)
		level.queue_free()

	level = preload("res://src/levels/level.tscn").instantiate() as Level
	add_child(level)
	level.load_level_data(Utils.b64_decode(data))

	_load_level_internal()


## Load a particular level that has been saved as a scene.
func load_level(level_scene: PackedScene):
	if level != null:
		remove_child(level)
		level.queue_free()

	# Instantiate the level, but don't add it to the tree.
	level = level_scene.instantiate() as Level
	# Call our faux-ready function (see documentation).
	level.post_init()

	# Reload the level data to hook up all the right signals.
	var result := level.save_level_data()
	if not result[0]:
		push_error("Could not save level data.")
		return
	level.load_level_data(result[1])

	# Only now add the level to the scene tree.
	add_child(level)

	_load_level_internal()


## Loads the level stored in the `level` node. Do not call this function directly.
func _load_level_internal():

	var tile_map := level.get_node("TileMap/Ground") as TileMapLayer


	level.get_node("Objects/LevelEnd").exit_reached_success.connect(self._on_LevelEnd_exit_reached_success)

	$CanvasLayer/UI.show()

	$CanvasLayer/UI/V/LevelName.text = level.level_name
	if level.text and not single_level:
		$CanvasLayer/UI/Textbox/MessageText.text = level.text
		$CanvasLayer/UI/Textbox.show()

	var start_tiles := tile_map.get_used_cells_by_id(START_TILE_SOURCE_ID, Vector2i(0, 0))

	assert(len(start_tiles) == 1)

	player = preload("res://src/objects/player.tscn").instantiate() as Node2D
	player.player_moved.connect(self._on_player_move)
	player.should_update_z_index.connect(self._on_player_should_update_z_index)
	player.position = tile_map.map_to_local(start_tiles[0])
	player.grid_coords = start_tiles[0]
	player.tile_map = tile_map
	level.add_child(player)
	reset_move_counter()

	update_timer()


func reload_level():
	var tile_map := level.get_node("TileMap/Ground") as TileMapLayer
	var start_tiles := tile_map.get_used_cells_by_id(START_TILE_SOURCE_ID, Vector2i(0, 0))

	assert(len(start_tiles) == 1)

	player.position = tile_map.map_to_local(start_tiles[0])
	player.grid_coords = start_tiles[0]
	player.reset_orientation()

	reset_move_counter()

func show_best_score():
	var best_score = Global.best_scores[Global.current_level_idx]
	if best_score != -1:
		best_move.text = "Best: %d" % best_score
		if best_score == level.perfect_score:
			star.show()
		else:
			star.hide()
	else:
		$CanvasLayer/UI/V/H.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		get_tree().paused = true
		hide_ui()
		$CanvasLayer/PauseMenu.show()
		$CanvasLayer/PauseMenu/C/V/Buttons/ResumeButton.grab_focus()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("restart"):
		reload_level()
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
	$CanvasLayer/LevelComplete.level = level
	$CanvasLayer/LevelComplete.update_text(moves)
	$CanvasLayer/LevelComplete.show()
	Global.update_best_scores(moves)
	hide_ui()


func _on_OptionsMenu_options_exited() -> void:
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


func go_to_menu() -> void:
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


func to_next_level() -> void:
	if single_level:
		go_to_menu()
	else:
		Global.current_level_idx += 1
		var next_level := Global.LEVELS[Global.current_level_idx]
		load_level(next_level)
