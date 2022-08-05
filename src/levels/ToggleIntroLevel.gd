extends Level


var wires := [Vector2(12, 1), Vector2(11, 1), Vector2(11, 0), Vector2(11, -1)]


func _ready() -> void:
	$Gate.init(false)


func _on_Toggle_toggled() -> void:
	$Gate.toggle()
	invert_wires(wires)
