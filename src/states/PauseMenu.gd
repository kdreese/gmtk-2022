extends CanvasLayer


func _ready() -> void:
	$ColorRect.hide()


func _unhandled_input(event: InputEvent) -> void:
	if not $ColorRect.visible:
		return
	if event.is_action_pressed("escape") or event.is_action_pressed("ui_cancel"):
		_on_ResumeButton_pressed()
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("restart"):
		_on_RestartButton_pressed()
		get_tree().set_input_as_handled()


func _on_ResumeButton_pressed() -> void:
	get_tree().paused = false
	$ColorRect.hide()
	get_parent().show_ui()


func _on_RestartButton_pressed() -> void:
	get_tree().paused = false
	var error := get_tree().reload_current_scene()
	assert(not error)


func _on_ToMenuButton_pressed() -> void:
	get_tree().paused = false
	var error := get_tree().change_scene("res://src/states/Menu.tscn")
	assert(not error)
