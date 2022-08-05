extends Node


const MAX_VOLUME_DB := -6.0
const SAVE_FILE_PATH := "user://config.cfg"
const BG_MUSIC = preload("res://assets/sound/Xetator.ogg")

const LEVELS = [
	{
		"name": "Introduction",
		"path": "res://src/levels/IntroLevel.tscn",
		"text": "Mr. Pip, Good morning Mr. Pip. Thank you for complying with this mandatory inspection. Please proceed to the ending pad.",
	},
	{
		"name": "Spiral",
		"path": "res://src/levels/MovementTutorialLevel.tscn",
		"text": "You have been arrested on suspicion of violating Legal Code 1379.42, or the \"No Weighted Dice Rule.\"",
	},
	{
		"name": "Free Reign",
		"path": "res://src/levels/MovementTestLevel.tscn",
		"text": "If you can pass all of our tests, you will prove that you are an unweighted die.\n\nFor example, that arrow is telling you you need to have that face on top or the end pad won\'t let you through.",
	},
	{
		"name": "Lopsided Patterns",
		"path": "res://src/levels/CycleTeachLevel.tscn",
		"text": "Press R on keyboard or RB on controller to restart the current test. Escape or Start will bring up the pause menu.\n\nThat\'s it from me, if there are any new elements, I will explain them.",
	},
	{
		"name": "Reverse Engineering",
		"path": "res://src/levels/CycleTrapLevel.tscn",
	},
	{
		"name": "Gate",
		"path": "res://src/levels/ButtonIntroLevel.tscn",
		"text": "This button won\'t activate unless you\'re in the right orientation. Once pressed, buttons stay pressed forever.",
	},
	{
		"name": "Between Two Points",
		"path": "res://src/levels/ButtonTestLevel.tscn",
	},
	{
		"name": "Optimization",
		"path": "res://src/levels/OptimizationLevel.tscn",
	},
	{
		"name": "On Again Off Again",
		"path": "res://src/levels/ToggleIntroLevel.tscn",
		"text": "This is a toggle. It can be hit multiple times.",
	},
	{
		"name": "Behind Closed Bars",
		"path": "res://src/levels/ButtonJailLevel.tscn",
	},
	{
		"name": "Commitment",
		"path": "res://src/levels/TestLevel.tscn",
	},
	{
		"name": "One Door Opens",
		"path": "res://src/levels/SomeKindaToggleLevel.tscn",
	},
	{
		"name": "Greed",
		"path": "res://src/levels/TwoPathsLevel.tscn",
	},
	{
		"name": "Hail Mary",
		"path": "res://src/levels/DangerButtonLevel.tscn",
		"text": "This is our last test for you. If you can pass it, you have truly proven yourself to be an unweighted die.",
	},
]

const NUM_LEVELS := len(LEVELS)

var current_level_idx: int

# Options
var sound_volume := 1.0
var music_volume := 0.5
var animation_speed := 1

var autosplitter_enabled := false
var autosplitter_port := 5678

var audio_stream: AudioStreamPlayer


func _ready() -> void:
	load_config()
	audio_stream = AudioStreamPlayer.new()
	audio_stream.stream = BG_MUSIC
	update_volumes()
	audio_stream.play()
	add_child(audio_stream)
	pause_mode = Node.PAUSE_MODE_PROCESS


func _notification(what: int) -> void:
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_config()
		get_tree().quit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
		save_config()
		get_tree().set_input_as_handled()


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


func load_config() -> void:
	var file := File.new()
	var error := file.open(SAVE_FILE_PATH, File.READ)
	if error:
		print("Error opening save file")
		return
	var config = str2var(file.get_as_text())
	file.close()

	if typeof(config) != TYPE_DICTIONARY:
		print("Save file corrupt")
		return

	if "sound_volume" in config:
		var new_volume = config["sound_volume"]
		if typeof(new_volume) == TYPE_REAL or typeof(new_volume) == TYPE_INT:
			sound_volume = float(new_volume)
			if sound_volume < 0.0:
				sound_volume = 0.0
			elif sound_volume > 1.0:
				sound_volume = 1.0

	if "music_volume" in config:
		var new_volume = config["music_volume"]
		if typeof(new_volume) == TYPE_REAL or typeof(new_volume) == TYPE_INT:
			music_volume = float(new_volume)
			if music_volume < 0.0:
				music_volume = 0.0
			elif music_volume > 1.0:
				music_volume = 1.0

	if "animation_speed" in config:
		var new_speed = config["animation_speed"]
		if typeof(new_speed) == TYPE_REAL or typeof(new_speed) == TYPE_INT:
			animation_speed = int(new_speed)
			if animation_speed < 0:
				animation_speed = 0
			elif animation_speed > 4:
				animation_speed = 4

	if "window_fullscreen" in config:
		var new_fullscreen = config["window_fullscreen"]
		if typeof(new_fullscreen) == TYPE_BOOL:
			OS.window_fullscreen = new_fullscreen

	if OS.get_name() != "HTML5":
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
		"sound_volume": sound_volume,
		"music_volume": music_volume,
		"animation_speed": animation_speed,
		"window_fullscreen": OS.window_fullscreen,
	}

	if OS.get_name() != "HTML5":
		config["autosplitter_enabled"] = autosplitter_enabled
		config["autosplitter_port"] = autosplitter_port

	var file := File.new()
	var error := file.open(SAVE_FILE_PATH, File.WRITE)
	if error:
		print("Error while writing save file")
		return

	file.store_line(var2str(config))
	file.close()
