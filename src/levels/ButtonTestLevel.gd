extends Level


var button1_wires := [Vector2(10, 2), Vector2(10, 3)]
var button2_wires := [Vector2(12, 2), Vector2(12, 3)]
var button3_wires := [Vector2(14, 2), Vector2(14, 3)]


func _ready() -> void:
	$Gate.init(false)
	$Gate2.init(false)
	$Gate3.init(false)
	$Gate4.init(false)
	$Gate5.init(false)


func _on_LevelButton_button_pressed() -> void:
	$Gate.open()
	$Gate2.open()
	invert_wires(button1_wires)


func _on_LevelButton2_button_pressed() -> void:
	$Gate3.open()
	$Gate4.open()
	invert_wires(button2_wires)

func _on_LevelButton3_button_pressed() -> void:
	$Gate5.open()
	invert_wires(button3_wires)
