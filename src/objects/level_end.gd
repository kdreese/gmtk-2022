class_name LevelEnd
extends LevelObject


signal exit_reached_success
signal exit_reached_incomplete


func get_object_type() -> int:
	return LEVEL_END


func get_position_offset() -> Vector2:
	return Vector2(0, -16)


func _ready() -> void:
	update_weight_display()


func update_weight_display() -> void:
	if minimum_weight == 1 and maximum_weight == 6:
		$Indicator.hide()
	else:
		$Indicator.show()
		$Indicator.set_text(str(minimum_weight))


func _on_LevelEnd_area_entered(area: Area2D) -> void:
	if area.name != "Player":
		return
	var face_value = area.get_top_face_value()
	if face_value >= minimum_weight and face_value <= maximum_weight:
		exit_reached_success.emit()
		if get_node_or_null("Indicator") != null:
			$Indicator.hide()
		$FinishSound.play()
	else:
		exit_reached_incomplete.emit()
