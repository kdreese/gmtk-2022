class_name Toggle
extends LevelObject

signal toggled


func get_object_type() -> int:
	return TOGGLE


func get_position_offset() -> Vector2:
	return Vector2.ZERO


func _ready() -> void:
	update_weight_display()


func update_weight_display() -> void:
	if minimum_weight == 1 and maximum_weight == 6:
		$Indicator.hide()
	else:
		$Indicator.show()
		$Indicator.set_text(str(minimum_weight))


func _on_Toggle_area_entered(area: Area2D) -> void:
	var face_value = area.get_top_face_value()
	if face_value >= minimum_weight and face_value <= maximum_weight:
		change_sprite()
		toggled.emit()
		$PressedSound.play()


func change_sprite() -> void:
	if $AnimatedSprite2D.animation == "on":
		$AnimatedSprite2D.play("off")
	else:
		$AnimatedSprite2D.play("on")
