extends CanvasLayer


signal options_exited

var animation_speed_strings := ["Slow", "Normal", "Fast", "Very Fast", "Disabled"]


func _ready() -> void:
	var animation_speed_value = Global.animation_speed / 2.0
	$ColorRect/C/V/G/AnimationSpeedSlider.value = animation_speed_value
	_on_AnimationSpeedSlider_value_changed(animation_speed_value)
	$ColorRect/C/V/G/MusicVolumeSlider.value = Global.music_slider_value
	_on_MusicVolumeSlider_value_changed(Global.music_slider_value)
	$ColorRect.hide()


func _unhandled_input(event: InputEvent) -> void:
	if not $ColorRect.visible:
		return
	if event.is_action_pressed("escape"):
		_on_BackButton_pressed()
		get_tree().set_input_as_handled()


func _on_BackButton_pressed() -> void:
	$ColorRect.hide()
	emit_signal("options_exited")


func _on_MusicVolumeSlider_value_changed(value: float) -> void:
	Global.set_music_volume(value)
	var label = $ColorRect/C/V/G/MusicVolumeLabel
	label.text = "%d%%" % (value * 100)


func _on_AnimationSpeedSlider_value_changed(value: float) -> void:
	Global.animation_speed = value * 2
	var label = $ColorRect/C/V/G/AnimationSpeedLabel
	label.text = animation_speed_strings[value]
