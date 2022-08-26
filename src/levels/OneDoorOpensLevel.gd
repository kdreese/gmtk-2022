extends Level


const LEVELBUTTON_WIRES = [
	Vector2(9, -2),
	Vector2(10, -2),
	Vector2(11, -2),
	Vector2(12, -2),
	Vector2(13, -2),
	Vector2(13, -1),
]


const TOGGLE_WIRES = [
	Vector2(10, 0),
	Vector2(10, 1),
	Vector2(10, 2),
	Vector2(11, 2),
	Vector2(12, 2),
	Vector2(13, 2),
	Vector2(13, 1),
	Vector2(14, 1),
]


func _on_Toggle_toggled() -> void:
	$YSort/Gate.toggle()
	$YSort/Gate2.toggle()
	$YSort/Gate3.toggle()
	invert_wires(TOGGLE_WIRES)


func _on_LevelButton_button_pressed() -> void:
	$YSort/Gate.toggle()
	invert_wires(LEVELBUTTON_WIRES)
