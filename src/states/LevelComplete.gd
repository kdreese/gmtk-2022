extends ColorRect


func update_text(moves: int) -> void:
	var level_info: Dictionary = Global.LEVELS[Global.current_level_idx]
	$C/V/Congratulations.text = "Congratulations! You finished %s.\nYour score: %d" % [level_info.name, moves]
	if moves < level_info.perfect_score:
		$C/V/Congratulations.text += "\nWow, you beat the perfect score of %d!\nTell us how you did it on our itch page." % level_info.perfect_score
	elif moves == level_info.perfect_score:
		$C/V/Congratulations.text += "\nYou got the perfect score of %d!" % level_info.perfect_score
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
