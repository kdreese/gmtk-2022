extends Level


var button1_wires := [
	Vector3(12, 2, 0),
	Vector3(13, 2, 0),
	Vector3(14, 2, 0),
	Vector3(15, 2, 0),
	Vector3(15, 1, 0),
	Vector3(15, 0, 0),
	Vector3(15, -1, 0),
	Vector3(14, -1, 1),
	Vector3(13, -1, 1)
]
var button2_wires := [
	Vector3(12, 1, 0),
	Vector3(13, 1, 0),
	Vector3(14, 1, 0),
	Vector3(14, 0, 0),
	Vector3(14, -1, 0),
	Vector3(14, -2, 0),
	Vector3(13, -2, 1)
]
var button3_wires := [
	Vector3(12, 0, 0),
	Vector3(13, 0, 0),
	Vector3(13, -1, 0),
	Vector3(13, -2, 0),
	Vector3(13, -3, 0),
]


func _ready() -> void:
	$Gate2.open()


func _on_LevelButton_button_pressed() -> void:
	$Gate3.open()
	invert_wires_3(button1_wires)


func _on_LevelButton2_button_pressed() -> void:
	$Gate2.close()
	invert_wires_3(button2_wires)


func _on_LevelButton3_button_pressed() -> void:
	$Gate.open()
	invert_wires_3(button3_wires)
