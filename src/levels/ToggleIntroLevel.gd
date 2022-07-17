extends Level


var wires := [Vector2(12, 1), Vector2(11, 1), Vector2(11, 0), Vector2(11, -1)]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_Toggle_toggled() -> void:
	$Gate.toggle()
	invert_wires(wires)
