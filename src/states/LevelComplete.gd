extends CanvasLayer


var next_level_path: String


func _ready() -> void:
	$ColorRect.hide()


func update(next_level_path_arg: String) -> void:
	$ColorRect/C/V/Congratulations.text = "Congratulations!\nYou finished the level in %d moves!" % get_parent().moves
	next_level_path = next_level_path_arg
	$ColorRect/C/V/Buttons/ContinueButton.grab_focus()
	if next_level_path.length() == 0:
		$ColorRect/C/V/Buttons/ContinueButton.hide()
		$ColorRect/C/V/Buttons/RestartButton.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().paused = false
		var error := get_tree().reload_current_scene()
		assert(not error)
		get_tree().set_input_as_handled()


func _on_ContinueButton_pressed() -> void:
	get_tree().paused = false
	Global.level_path = next_level_path
	var error := get_tree().reload_current_scene()
	assert(not error)


func _on_RestartButton_pressed() -> void:
	get_tree().paused = false
	var error := get_tree().reload_current_scene()
	assert(not error)


func _on_ToMenuButton_pressed() -> void:
	get_tree().paused = false
	var error := get_tree().change_scene("res://src/states/Menu.tscn")
	assert(not error)
