extends Node


const MAX_VOLUME_DB := -6.0
const SAVE_FILE_PATH := "user://config.cfg"
const FIRST_LEVEL_PATH := "res://src/levels/IntroLevel.tscn"

const BG_MUSIC = preload("res://assets/sound/Xetator.ogg")

var level_path: String

# Options
var sound_volume := 1.0
var music_volume := 0.5
var animation_speed := 1

var audio_stream: AudioStreamPlayer


func _ready() -> void:
	load_config()
	audio_stream = AudioStreamPlayer.new()
	audio_stream.stream = BG_MUSIC
	audio_stream.pause_mode = Node.PAUSE_MODE_PROCESS
	update_volumes()
	audio_stream.play()
	add_child(audio_stream)


func _notification(what: int) -> void:
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_config()
		get_tree().quit()


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


func save_config() -> void:
	var config := {
		"sound_volume": sound_volume,
		"music_volume": music_volume,
		"animation_speed": animation_speed,
	}

	var file := File.new()
	var error := file.open(SAVE_FILE_PATH, File.WRITE)
	if error:
		print("Error while writing save file")
		return

	file.store_line(var2str(config))
	file.close()
