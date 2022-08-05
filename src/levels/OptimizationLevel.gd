extends Level


var wires := [Vector2(12, 1), Vector2(13, 1), Vector2(14, 1), Vector2(15, 1)]


func _ready() -> void:
	$Gate.init(false)


func _on_LevelButton_button_pressed() -> void:
	$Gate.open()
	invert_wires(wires)
