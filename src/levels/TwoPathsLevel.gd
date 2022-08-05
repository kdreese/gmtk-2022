extends Level


var button1_wires := [
	Vector3(10, 3, 0),
	Vector3(9, 3, 0),
	Vector3(9, 2, 0),
	Vector3(9, 1, 1),
	Vector3(9, 0, 0),
	Vector3(9, -1, 0),
	Vector3(9, -2, 0),
	Vector3(10, -2, 0)
]
var button2_wires := [
	Vector3(8, 3, 0),
	Vector3(8, 2, 0),
	Vector3(8, 1, 0),
	Vector3(9, 1, 0),
	Vector3(10, 1, 0),
	Vector3(10, 0, 0),
	Vector3(11, 0, 0),
	Vector3(12, 0, 0),
]
var button3_wires := [
	Vector3(7, 3, 0),
	Vector3(7, 2, 0),
	Vector3(7, 1, 0),
	Vector3(7, 0, 0),
	Vector3(7, -1, 0),
	Vector3(7, -2, 0),
	Vector3(7, -3, 0),
	Vector3(8, -3, 0),
	Vector3(9, -3, 0),
	Vector3(10, -3, 0),
	Vector3(11, -3, 0),
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Gate.init(false)
	$Gate2.init(false)
	$Gate3.init(false)
	$Gate4.init(true)


func _on_LevelButton_button_pressed() -> void:
	$Gate3.open()
	invert_wires_3(button1_wires)


func _on_LevelButton2_button_pressed() -> void:
	$Gate4.close()
	$Gate2.open()
	invert_wires_3(button2_wires)


func _on_LevelButton3_button_pressed() -> void:
	$Gate.open()
	invert_wires_3(button3_wires)
