extends Control


signal load_level(code: String)


func show_menu() -> void:
	show()
	%LineEdit.text = ""
	%LineEdit.grab_focus()


func on_cancel_button_pressed() -> void:
	hide()


func on_load_button_pressed() -> void:
	load_level.emit(%LineEdit.text)
	hide()
