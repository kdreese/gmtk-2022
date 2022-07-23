extends ColorRect


var next_level_path: String


func update_text(next_level_path_arg: String) -> void:
	$C/V/Congratulations.text = "Congratulations!\nYou finished the level in %d moves!" % get_node("../..").moves
	next_level_path = next_level_path_arg
	$C/V/Buttons/ContinueButton.grab_focus()
	if next_level_path.length() == 0:
		$C/V/YouWinLabel.show()
		$C/V/Buttons/ContinueButton.hide()
		$C/V/Buttons/RestartButton.grab_focus()


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
