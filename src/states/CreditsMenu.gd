extends CanvasLayer


signal credits_exiting

const SCROLL_SPEED := 1000.0


func _ready() -> void:
	$ColorRect.hide()


func _process(delta: float) -> void:
	var axis := Input.get_axis("ui_up", "ui_down")
	$ColorRect/V/S.scroll_vertical += int(axis * delta * SCROLL_SPEED)


func show_menu() -> void:
	$ColorRect/V/S.scroll_vertical = 0
	$ColorRect.show()
	$ColorRect/BackButton.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not $ColorRect.visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_BackButton_pressed()
		get_tree().set_input_as_handled()


func _on_BackButton_pressed() -> void:
	$ColorRect.hide()
	emit_signal("credits_exiting")
