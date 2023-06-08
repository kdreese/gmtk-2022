extends ColorRect


signal credits_exiting

const SCROLL_SPEED := 1000.0


func _process(delta: float) -> void:
	var axis := Input.get_axis("ui_up", "ui_down")
	$V/S.scroll_vertical += int(axis * delta * SCROLL_SPEED)


func show_menu() -> void:
	$V/S.scroll_vertical = 0
	show()
	$BackButton.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_BackButton_pressed()
		get_viewport().set_input_as_handled()


func _on_BackButton_pressed() -> void:
	hide()
	emit_signal("credits_exiting")
