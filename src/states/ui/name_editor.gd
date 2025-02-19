extends Control


signal name_chosen(name: String)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		on_ok_button_press()
	elif event.is_action_pressed("ui_cancel"):
		on_cancel_button_press()


func open_window(previous_name: String = "") -> void:
	show()
	%LineEdit.text = previous_name
	%LineEdit.grab_focus()
	%LineEdit.select_all()


func on_ok_button_press() -> void:
	name_chosen.emit(%LineEdit.text)
	hide()


func on_cancel_button_press() -> void:
	hide()
