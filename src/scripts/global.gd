extends Node


const MAX_VOLUME_DB := -6.0
const SAVE_FILE_PATH := "user://config.cfg"
const BG_MUSIC = preload("res://assets/sound/Xetator.ogg")

const LEVELS : Array[PackedScene] = [
	preload("res://src/levels/introduction_level.tscn"),
	preload("res://src/levels/spiral_level.tscn"),
	preload("res://src/levels/free_reign_level.tscn"),
	preload("res://src/levels/lopsided_patterns_level.tscn"),
	preload("res://src/levels/reverse_engineering_level.tscn"),
	preload("res://src/levels/gate_level.tscn"),
	preload("res://src/levels/between_two_points_level.tscn"),
	preload("res://src/levels/optimization_level.tscn"),
	preload("res://src/levels/on_again_off_again_level.tscn"),
	preload("res://src/levels/behind_closed_bars_level.tscn"),
	preload("res://src/levels/commitment_level.tscn"),
	preload("res://src/levels/one_door_opens_level.tscn"),
	preload("res://src/levels/greed_level.tscn"),
	preload("res://src/levels/hail_mary_level.tscn"),
]

const NUM_LEVELS := len(LEVELS)

var current_level_idx: int
var best_scores := []

# Options
var sound_volume := 1.0
var music_volume := 0.5
var animation_speed := 1

var speedrun_timer_enabled := false
var autosplitter_enabled := false
var autosplitter_port := 5678

var audio_stream: AudioStreamPlayer

var level_to_load: PackedByteArray = []


func _ready() -> void:
	if not OS.has_feature("web"):
		@warning_ignore("integer_division")
		var window_size_multiplier := DisplayServer.screen_get_size().x / (2 * 640)
		get_window().size *= window_size_multiplier
		#OS.center_window() # the lines below do this
		var screen_id := get_window().current_screen
		var screen_center := DisplayServer.screen_get_position(screen_id) \
				+ DisplayServer.screen_get_size(screen_id) / 2
		get_window().position = screen_center - get_window().size / 2
	for _idx in range(NUM_LEVELS):
		best_scores.append(-1)
	load_config()
	audio_stream = AudioStreamPlayer.new()
	audio_stream.stream = BG_MUSIC
	update_volumes()
	add_child(audio_stream)
	audio_stream.play()
	process_mode = Node.PROCESS_MODE_ALWAYS


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_config()
		get_tree().quit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		if OS.has_feature("web"):
			return
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (not ((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED
		save_config()
		get_viewport().set_input_as_handled()


func update_volumes() -> void:
	# Volume is given as a percent, so change that to dB.
	var sounds_bus_index := AudioServer.get_bus_index("SoundsBus")
	AudioServer.set_bus_volume_db(sounds_bus_index, MAX_VOLUME_DB + (20 * log(sound_volume) / log(10)))
	audio_stream.volume_db = MAX_VOLUME_DB + (20 * log(music_volume) / log(10))


func set_sound_volume(new_volume: float) -> void:
	sound_volume = new_volume
	if sound_volume < 0.0:
		sound_volume = 0.0
	elif sound_volume > 1.0:
		sound_volume = 1.0
	update_volumes()


func set_music_volume(new_volume: float) -> void:
	music_volume = new_volume
	if music_volume < 0.0:
		music_volume = 0.0
	elif music_volume > 1.0:
		music_volume = 1.0
	update_volumes()


func update_best_scores(new_score: int) -> void:
	if new_score < best_scores[current_level_idx] or best_scores[current_level_idx] < 0:
		best_scores[current_level_idx] = new_score
		save_config()


func load_config() -> void:
	if not DirAccess.dir_exists_absolute("user://levels"):
		DirAccess.make_dir_absolute("user://levels")

	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var error := FileAccess.get_open_error()
	if error == ERR_FILE_NOT_FOUND:
		print("No config file found, using default settings")
		return
	if error:
		push_warning("Error opening save file, using default settings")
		return
	var config = str_to_var(file.get_as_text())
	file.close()

	if typeof(config) != TYPE_DICTIONARY:
		push_warning("Save file corrupt, using default settings")
		return

	if "best_scores" in config:
		var new_best_scores = config["best_scores"]
		if typeof(new_best_scores) == TYPE_ARRAY:
			for idx in range(min(new_best_scores.size(), NUM_LEVELS)):
				if typeof(new_best_scores[idx]) == TYPE_FLOAT or typeof(new_best_scores[idx]) == TYPE_INT:
					best_scores[idx] = int(new_best_scores[idx])

	if "sound_volume" in config:
		var new_volume = config["sound_volume"]
		if typeof(new_volume) == TYPE_FLOAT or typeof(new_volume) == TYPE_INT:
			sound_volume = float(new_volume)
			if sound_volume < 0.0:
				sound_volume = 0.0
			elif sound_volume > 1.0:
				sound_volume = 1.0

	if "music_volume" in config:
		var new_volume = config["music_volume"]
		if typeof(new_volume) == TYPE_FLOAT or typeof(new_volume) == TYPE_INT:
			music_volume = float(new_volume)
			if music_volume < 0.0:
				music_volume = 0.0
			elif music_volume > 1.0:
				music_volume = 1.0

	if "animation_speed" in config:
		var new_speed = config["animation_speed"]
		if typeof(new_speed) == TYPE_FLOAT or typeof(new_speed) == TYPE_INT:
			animation_speed = int(new_speed)
			if animation_speed < 0:
				animation_speed = 0
			elif animation_speed > 4:
				animation_speed = 4

	if "window_fullscreen" in config:
		var new_fullscreen = config["window_fullscreen"]
		if typeof(new_fullscreen) == TYPE_BOOL:
			get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (new_fullscreen) else Window.MODE_WINDOWED

	if "speedrun_timer_enabled" in config:
		var new_speedrun = config["speedrun_timer_enabled"]
		if typeof(new_speedrun) == TYPE_BOOL:
			speedrun_timer_enabled = new_speedrun

	if not OS.has_feature("web"):
		if "autosplitter_enabled" in config:
			var new_autosplitter_enabled = config["autosplitter_enabled"]
			if typeof(new_autosplitter_enabled) == TYPE_BOOL:
				autosplitter_enabled = new_autosplitter_enabled

		if "autosplitter_port" in config:
			var new_port = config["autosplitter_port"]
			if typeof(new_port) == TYPE_INT:
				autosplitter_port = new_port
				if autosplitter_port < 0:
					autosplitter_port = 0
				elif autosplitter_port > 65535:
					autosplitter_port = 65535


func save_config() -> void:
	var config := {
		"best_scores": best_scores,
		"sound_volume": sound_volume,
		"music_volume": music_volume,
		"animation_speed": animation_speed,
		"window_fullscreen": ((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN)),
		"speedrun_timer_enabled": speedrun_timer_enabled
	}

	if not OS.has_feature("web"):
		config["autosplitter_enabled"] = autosplitter_enabled
		config["autosplitter_port"] = autosplitter_port

	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Could not open config file for writing!")
		return

	file.store_line(var_to_str(config))
	file.close()


# TileSet.find_tile_by_name doesn't exist in Godot 4, so I'm implementing a version here.
# Returns a source id from a given TileSet with the matching resource_name.
func find_source_id_by_name(tile_set: TileSet, tile_name: String) -> int:
	for source_id in range(tile_set.get_source_count()):
		var source := tile_set.get_source(source_id)
		if source.resource_name == tile_name:
			return source_id
	return -1
