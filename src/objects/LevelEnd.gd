class_name LevelEnd
extends Area2D


signal exit_reached_success
signal exit_reached_incomplete

export var minimum_weight: int = 1
export var maximum_weight: int = 6
export var next_level_path: String = ""


func _on_LevelEnd_area_entered(area: Area2D) -> void:
	var face_value = area.get_top_face_value()
	if face_value >= minimum_weight and face_value <= maximum_weight:
		emit_signal("exit_reached_success", next_level_path)
		$Indicator.hide()
	else:
		emit_signal("exit_reached_incomplete")
