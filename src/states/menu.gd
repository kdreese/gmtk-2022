extends CenterContainer


func _ready() -> void:
	if OS.has_feature("web"):
		%QuitButton.hide()
	%PlayButton.grab_focus()
	Global.current_level_idx = 0


func _on_PlayButton_pressed() -> void:
	var game := preload("res://src/states/game.tscn").instantiate() as Game
	get_tree().root.add_child(game)
	get_tree().set_current_scene(game)
	get_tree().root.remove_child(self)
	game.play_campaign()
	Autosplitter.run_start()


func _on_LevelSelectButton_pressed() -> void:
	$V.hide()
	$Canvas/LevelSelect.show_menu()


func to_level_editor() -> void:
	get_tree().change_scene_to_file("res://src/states/level_editor.tscn")


func _on_OptionsButton_pressed() -> void:
	$V.hide()
	$Canvas/OptionsMenu.show_menu()


func _on_CreditsButton_pressed() -> void:
	$V.hide()
	$Canvas/CreditsMenu.show_menu()


func _on_QuitButton_pressed() -> void:
	get_tree().get_root().propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)


func _on_LevelSelect_level_select_exited() -> void:
	$V.show()
	%LevelSelectButton.grab_focus()


func _on_OptionsMenu_options_exited() -> void:
	$V.show()
	%OptionsButton.grab_focus()


func _on_CreditsMenu_credits_exiting() -> void:
	$V.show()
	%CreditsButton.grab_focus()
