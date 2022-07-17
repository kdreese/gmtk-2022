extends CenterContainer


func _ready() -> void:
	if OS.get_name() == "HTML5":
		$V/Buttons/QuitButton.hide()
	$V/Buttons/PlayButton.grab_focus()
	Global.level_path = Global.FIRST_LEVEL_PATH


func _on_PlayButton_pressed() -> void:
	var error := get_tree().change_scene("res://src/states/Game.tscn")
	assert(not error)


func _on_LevelSelectButton_pressed() -> void:
	$V.hide()
	$LevelSelect.load_levels()
	$LevelSelect/ColorRect.show()
	$LevelSelect/ColorRect/C/V/G.get_children()[0].grab_focus()


func _on_OptionsButton_pressed() -> void:
	$V.hide()
	$OptionsMenu.show_menu()


func _on_CreditsButton_pressed() -> void:
	$V.hide()
	$CreditsMenu.show_menu()


func _on_QuitButton_pressed() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func _on_LevelSelect_level_select_exited() -> void:
	$V.show()
	$V/Buttons/LevelSelectButton.grab_focus()


func _on_OptionsMenu_options_exited() -> void:
	$V.show()
	$V/Buttons/OptionsButton.grab_focus()


func _on_CreditsMenu_credits_exiting() -> void:
	$V.show()
	$V/Buttons/CreditsButton.grab_focus()
