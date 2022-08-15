extends ColorRect


func update_text() -> void:
	$C/V/Congratulations.text = "Congratulations!\nYou finished the level in %d moves!" % get_node("../..").moves
	$C/V/Buttons/ContinueButton.grab_focus()
	if Global.current_level_idx >= Global.NUM_LEVELS - 1:
		$C/V/YouWinLabel.show()
		$C/V/Buttons/ContinueButton.hide()
		$C/V/Buttons/RestartButton.grab_focus()
		Autosplitter.run_finish()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().paused = false
		var error := get_tree().reload_current_scene()
		assert(not error)
		get_tree().set_input_as_handled()


func _on_ContinueButton_pressed() -> void:
	get_tree().paused = false
	Global.current_level_idx += 1
	var error := get_tree().reload_current_scene()
	assert(not error)


func _on_RestartButton_pressed() -> void:
	get_tree().paused = false
	var error := get_tree().reload_current_scene()
	assert(not error)


func _on_ToMenuButton_pressed() -> void:
	get_tree().paused = false
	Autosplitter.run_reset()
	var error := get_tree().change_scene("res://src/states/Menu.tscn")
	assert(not error)
