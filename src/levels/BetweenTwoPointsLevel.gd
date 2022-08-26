extends Level


var button1_wires := [Vector2(10, 2), Vector2(10, 3)]
var button2_wires := [Vector2(12, 2), Vector2(12, 3)]
var button3_wires := [Vector2(14, 2), Vector2(14, 3)]


func _on_LevelButton_button_pressed() -> void:
	$YSort/Gate.open()
	$YSort/Gate2.open()
	invert_wires(button1_wires)


func _on_LevelButton2_button_pressed() -> void:
	$YSort/Gate3.open()
	$YSort/Gate4.open()
	invert_wires(button2_wires)

func _on_LevelButton3_button_pressed() -> void:
	$YSort/Gate5.open()
	invert_wires(button3_wires)
