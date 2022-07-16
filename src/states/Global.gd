extends Node


const MAX_VOLUME_DB = -6.0

var level_path: String

var bg_music = preload("res://assets/sound/Xetator.wav")

# Options
var music_slider_value = 1.0
var music_volume = 1.0
var animation_speed = 2.0

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
	music_slider_value = volume
	audio_stream.volume_db = MAX_VOLUME_DB + (log(volume) / log(1.1))
