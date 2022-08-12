extends Level


var toggle_wires := [
	Vector2(12, 3),
	Vector2(12, 4)
]
var button_wires := [
	Vector2(10, 3),
	Vector2(10, 4),
	Vector2(10, 5),
	Vector2(10, 6),
	Vector2(11, 6),
	Vector2(12, 6),
]


func _on_Toggle_toggled() -> void:
	$Gate.toggle()
	invert_wires(toggle_wires)


func _on_LevelButton_button_pressed() -> void:
	$Gate2.open()
	invert_wires(button_wires)
