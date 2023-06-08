extends ColorRect


func _ready() -> void:
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("escape") or event.is_action_pressed("ui_cancel"):
		resume()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("restart"):
		restart()
		get_viewport().set_input_as_handled()


func resume() -> void:
	get_tree().paused = false
	hide()
	get_node("../..").show_ui()


func restart() -> void:
	get_tree().paused = false
	var error := get_tree().reload_current_scene()
	assert(not error)


func _on_ToMenuButton_pressed() -> void:
	get_tree().paused = false
	Autosplitter.run_reset()
	var error := get_tree().change_scene_to_file("res://src/states/menu.tscn")
	assert(not error)
