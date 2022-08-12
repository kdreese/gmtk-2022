extends ColorRect


signal options_exited

var animation_speed_strings := ["Slow", "Normal", "Fast", "Very Fast", "Hyperspeed"]

onready var fullscreen_option_button: OptionButton = $C/V/G/FullscreenOptionButton


func _ready() -> void:
	fullscreen_option_button.add_item("Windowed")
	fullscreen_option_button.add_item("Fullscreen")

	$C/V/G/SoundVolumeSlider.value = Global.sound_volume
	$C/V/G/MusicVolumeSlider.value = Global.music_volume
	$C/V/G/AnimationSpeedSlider.value = Global.animation_speed
	fullscreen_option_button.select(1 if OS.window_fullscreen else 0)
	if OS.get_name() == "HTML5":
		$C/V/V.hide()
	else:
		$C/V/V/H/AutosplitterEnabledCheck.pressed = Global.autosplitter_enabled
		$C/V/V/H/AutosplitterPortSpinBox.value = Global.autosplitter_port


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
	$C/V/BackButton.grab_focus()


func close_menu() -> void:
	hide()
	emit_signal("options_exited")
	Global.save_config()


func _on_SoundVolumeSlider_value_changed(value: float) -> void:
	Global.set_sound_volume(value)
	$C/V/G/SoundVolumeLabel.text = "%d%%" % (value * 100)


func _on_MusicVolumeSlider_value_changed(value: float) -> void:
	Global.set_music_volume(value)
	$C/V/G/MusicVolumeLabel.text = "%d%%" % (value * 100)


func _on_AnimationSpeedSlider_value_changed(value: float) -> void:
	Global.animation_speed = int(value)
	$C/V/G/AnimationSpeedLabel.text = animation_speed_strings[value]


func _on_FullscreenOptionsButton_item_selected(index: int) -> void:
	OS.window_fullscreen = (index == 1)


func _on_AutosplitterEnabledCheck_toggled(button_pressed: bool) -> void:
	if button_pressed:
		$C/V/V/H/AutosplitterPortSpinBox.editable = false
		Autosplitter.start()
		if not Global.autosplitter_enabled:
			$C/V/V/H/AutosplitterEnabledCheck.pressed = false
	else:
		$C/V/V/H/AutosplitterPortSpinBox.editable = true
		Autosplitter.stop()


func _on_AutosplitterPortSpinBox_value_changed(float_value: float) -> void:
	var value := int(float_value)
	Global.autosplitter_port = value
