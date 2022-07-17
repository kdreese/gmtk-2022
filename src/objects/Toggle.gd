extends Area2D

signal toggled

export var minimum_weight: int = 1
export var maximum_weight: int = 6


func _ready() -> void:
	if minimum_weight == 1 and maximum_weight == 6:
		$Indicator.hide()


func _on_Toggle_area_entered(area: Area2D) -> void:
	var face_value = area.get_top_face_value()
	if face_value >= minimum_weight and face_value <= maximum_weight:
		$Indicator.hide()
		emit_signal("toggled")
		$PressedSound.play()
