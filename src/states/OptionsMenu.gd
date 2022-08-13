extends ColorRect


signal options_exited

var animation_speed_strings := ["Slow", "Normal", "Fast", "Very Fast", "Hyperspeed"]

onready var back_button: Button = $"%BackButton"

onready var sound_volume_slider: HSlider = $"%SoundVolumeSlider"
onready var music_volume_slider: HSlider = $"%MusicVolumeSlider"
onready var animation_speed_slider: HSlider = $"%AnimationSpeedSlider"
onready var fullscreen_option_button: OptionButton = $"%FullscreenOptionButton"

onready var sound_volume_label: Label = $"%SoundVolumeLabel"
onready var music_volume_label: Label = $"%MusicVolumeLabel"
onready var animation_speed_label: Label = $"%AnimationSpeedLabel"

onready var speedrun_timer_check: CheckButton = $"%SpeedrunTimerCheck"
onready var livesplit_settings: HBoxContainer = $"%LivesplitSettings"
onready var autosplitter_enabled_check: CheckButton = $"%AutosplitterEnabledCheck"
onready var autosplitter_port_spin_box: SpinBox = $"%AutosplitterPortSpinBox"


func _ready() -> void:
	fullscreen_option_button.add_item("Windowed")
	fullscreen_option_button.add_item("Fullscreen")

	sound_volume_slider.value = Global.sound_volume
	music_volume_slider.value = Global.music_volume
	animation_speed_slider.value = Global.animation_speed
	fullscreen_option_button.select(1 if OS.window_fullscreen else 0)
	speedrun_timer_check.pressed = Global.speedrun_timer_enabled
	if OS.get_name() == "HTML5":
		livesplit_settings.hide()
	else:
		autosplitter_enabled_check.pressed = Global.autosplitter_enabled
		autosplitter_port_spin_box.value = Global.autosplitter_port


func _process(_delta: float) -> void:
	if OS.window_fullscreen != (fullscreen_option_button.selected == 1):
		fullscreen_option_button.select(1 if OS.window_fullscreen else 0)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close_menu()
		get_tree().set_input_as_handled()


func show_menu() -> void:
	show()
	back_button.grab_focus()


func close_menu() -> void:
	hide()
	emit_signal("options_exited")
	Global.save_config()


func _on_SoundVolumeSlider_value_changed(value: float) -> void:
	Global.set_sound_volume(value)
	sound_volume_label.text = "%d%%" % (value * 100)


func _on_MusicVolumeSlider_value_changed(value: float) -> void:
	Global.set_music_volume(value)
	music_volume_label.text = "%d%%" % (value * 100)


func _on_AnimationSpeedSlider_value_changed(value: float) -> void:
	Global.animation_speed = int(value)
	animation_speed_label.text = animation_speed_strings[value]


func _on_FullscreenOptionsButton_item_selected(index: int) -> void:
	OS.window_fullscreen = (index == 1)


func _on_SpeedrunTimerCheck_toggled(button_pressed: bool) -> void:
	Global.speedrun_timer_enabled = button_pressed


func _on_AutosplitterEnabledCheck_toggled(button_pressed: bool) -> void:
	if button_pressed:
		autosplitter_port_spin_box.editable = false
		Autosplitter.start()
		if not Global.autosplitter_enabled:
			autosplitter_enabled_check.pressed = false
	else:
		autosplitter_port_spin_box.editable = true
		Autosplitter.stop()


func _on_AutosplitterPortSpinBox_value_changed(float_value: float) -> void:
	var value := int(float_value)
	Global.autosplitter_port = value
