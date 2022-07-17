extends CanvasLayer


signal options_exited

var animation_speed_strings := ["Slow", "Normal", "Fast", "Very Fast", "Hyperspeed"]


func _ready() -> void:
	var animation_speed_value = Global.animation_speed
	$ColorRect/C/V/G/AnimationSpeedSlider.value = animation_speed_value
	_on_AnimationSpeedSlider_value_changed(animation_speed_value)
	$ColorRect/C/V/G/MusicVolumeSlider.value = Global.music_volume
	_on_MusicVolumeSlider_value_changed(Global.music_volume)
	$ColorRect.hide()


func _unhandled_input(event: InputEvent) -> void:
	if not $ColorRect.visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_BackButton_pressed()
		get_tree().set_input_as_handled()


func show_menu() -> void:
	$ColorRect.show()
	$ColorRect/C/V/BackButton.grab_focus()


func _on_BackButton_pressed() -> void:
	$ColorRect.hide()
	emit_signal("options_exited")


func _on_MusicVolumeSlider_value_changed(value: float) -> void:
	Global.set_music_volume(value)
	var label = $ColorRect/C/V/G/MusicVolumeLabel
	label.text = "%d%%" % (value * 100)


func _on_AnimationSpeedSlider_value_changed(value: float) -> void:
	Global.animation_speed = int(value)
	var label = $ColorRect/C/V/G/AnimationSpeedLabel
	label.text = animation_speed_strings[value]