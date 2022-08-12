extends CenterContainer


func _ready() -> void:
	if OS.get_name() == "HTML5":
		$V/Buttons/QuitButton.hide()
	$V/Buttons/PlayButton.grab_focus()
	Global.current_level_idx = 0
#	get_tree().get_root().set_transparent_background(true)		# Transparent background for screenshots


func _on_PlayButton_pressed() -> void:
	var error := get_tree().change_scene("res://src/states/Game.tscn")
	assert(not error)
	Autosplitter.send_data("start")


func _on_LevelSelectButton_pressed() -> void:
	$V.hide()
	$Canvas/LevelSelect.show_menu()


func _on_OptionsButton_pressed() -> void:
	$V.hide()
	$Canvas/OptionsMenu.show_menu()


func _on_CreditsButton_pressed() -> void:
	$V.hide()
	$Canvas/CreditsMenu.show_menu()


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
