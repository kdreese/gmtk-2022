extends CanvasLayer


func _ready() -> void:
	$ColorRect.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		if get_tree().paused:
			_on_ResumeButton_pressed()
		else:
			get_tree().paused = true
			$ColorRect.show()
			$ColorRect/C/V/Buttons/ResumeButton.grab_focus()
			get_tree().set_input_as_handled()


func _on_ResumeButton_pressed() -> void:
	get_tree().paused = false
	$ColorRect.hide()


func _on_RestartButton_pressed() -> void:
	get_tree().paused = false
	var error := get_tree().reload_current_scene()
	assert(not error)


func _on_ToMenuButton_pressed() -> void:
	get_tree().paused = false
	var error := get_tree().change_scene("res://src/states/Menu.tscn")
	assert(not error)
