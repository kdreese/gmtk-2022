extends CenterContainer


func _ready() -> void:
	if OS.get_name() == "HTML5":
		$V/Buttons/QuitButton.hide()
	$V/Buttons/PlayButton.grab_focus()


func _on_PlayButton_pressed() -> void:
	Global.level_path = "res://src/levels/TestLevel2.tscn"
	var error := get_tree().change_scene("res://src/states/Game.tscn")
	assert(not error)


func _on_CreditsButton_pressed() -> void:
	pass # TODO


func _on_QuitButton_pressed() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
