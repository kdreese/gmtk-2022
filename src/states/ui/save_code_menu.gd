extends Control


func show_menu(code: String) -> void:
	%Code.text = code
	%CopiedLabel.hide()
	show()


func on_cancel_button_pressed() -> void:
	hide()


func on_copy_button_pressed() -> void:
	DisplayServer.clipboard_set(%Code.text)
	%CopiedLabel.show()
