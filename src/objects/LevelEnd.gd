class_name LevelEnd
extends Area2D


signal exit_reached_success
signal exit_reached_incomplete

export var minimum_weight := 1
export var maximum_weight := 6
export var next_level_path := ""
export var level_name := ""
export(String, MULTILINE) var level_text = ""


func _ready() -> void:
	if minimum_weight == 1 and maximum_weight == 6:
		$Indicator.queue_free()


func _on_LevelEnd_area_entered(area: Area2D) -> void:
	var face_value = area.get_top_face_value()
	if face_value >= minimum_weight and face_value <= maximum_weight:
		emit_signal("exit_reached_success", next_level_path)
		if get_node_or_null("Indicator") != null:
			$Indicator.queue_free()
		$FinishSound.play()
	else:
		emit_signal("exit_reached_incomplete")
