extends ColorRect

## A reference to the current level
var level: Level

func update_text(moves: int) -> void:
	var finish_text := "Congratulations! You finished %s.\nYour score: %d" % [level.level_name, moves]
	if Global.current_level_idx != -1:
		var prev_best = Global.best_scores[Global.current_level_idx]
		if prev_best < 0 or moves < prev_best:
			finish_text += "      New best score!"
		else:
			finish_text += "      Your best: %d" % prev_best
		if moves < level.perfect_score:
			finish_text += "\nWow, you beat the perfect score of %d!\nTell us how you did it on our itch page." % \
					level.perfect_score
		elif moves == level.perfect_score:
			finish_text += "\nYou got the perfect score of %d!" % level.perfect_score
	if owner.single_level:
		$C/V/Buttons/ContinueButton.text = "Back"
	else:
		$C/V/Buttons/ContinueButton.text = "Next Level"
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
		owner.reload_level()
		get_viewport().set_input_as_handled()


func _on_ContinueButton_pressed() -> void:
	hide()
	get_tree().paused = false
	owner.to_next_level()


func _on_RestartButton_pressed() -> void:
	get_tree().paused = false
	owner.reload_level()


func _on_ToMenuButton_pressed() -> void:
	get_tree().paused = false
	Autosplitter.run_reset()
	owner.go_to_menu()
