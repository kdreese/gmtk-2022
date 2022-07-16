extends Node


const MAX_VOLUME_DB = -6.0

var level_path: String

var bg_music = preload("res://assets/sound/Xetator.ogg")

# Options
var music_volume := 0.5
var animation_speed := 1

var audio_stream: AudioStreamPlayer


func _ready() -> void:
	audio_stream = AudioStreamPlayer.new()
	audio_stream.stream = bg_music
	audio_stream.pause_mode = Node.PAUSE_MODE_PROCESS
	audio_stream.volume_db = MAX_VOLUME_DB
	audio_stream.play()
	add_child(audio_stream)


func set_music_volume(volume: float) -> void:
	# Volume is given as a percent, so change that to dB.
	music_volume = volume
	audio_stream.volume_db = MAX_VOLUME_DB + (20 * log(volume) / log(10))
