extends Level


func _ready() -> void:
	$Gate2.open()


func _on_LevelButton_button_pressed() -> void:
	$Gate.open()


func _on_LevelButton2_button_pressed() -> void:
	$Gate.close()


func _on_LevelButton3_button_pressed() -> void:
	$Gate3.open()
