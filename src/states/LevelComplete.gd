extends ColorRect


func update_text(moves: int) -> void:
	var level_info: Dictionary = Global.LEVELS[Global.current_level_idx]
	var finish_text := "Congratulations! You finished %s.\nYour score: %d" % [level_info.name, moves]
	var prev_best = Global.best_scores[Global.current_level_idx]
	if prev_best < 0 or moves < prev_best:
		finish_text += "      New best score!"
	else:
		finish_text += "      Your best: %d" % prev_best
	if moves < level_info.perfect_score:
		finish_text += "\nWow, you beat the perfect score of %d!\nTell us how you did it on our itch page." % \
				level_info.perfect_score
	elif moves == level_info.perfect_score:
		finish_text += "\nYou got the perfect score of %d!" % level_info.perfect_score
	$C/V/Congratulations.text = finish_text
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
		get_viewport().set_input_as_handled()


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
	var error := get_tree().change_scene_to_file("res://src/states/Menu.tscn")
	assert(not error)
