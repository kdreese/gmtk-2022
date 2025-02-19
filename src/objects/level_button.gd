class_name LevelButton
extends LevelObject


signal button_pressed

var unpressed_texture = preload("res://assets/objects/button.png")
var pressed_texture = preload("res://assets/objects/button_pressed.png")


func get_object_type() -> int:
	return BUTTON


func get_position_offset() -> Vector2:
	return Vector2.ZERO


func _ready() -> void:
	# Set the initial state to unpressed.
	$Sprite2D.texture = unpressed_texture
	update_weight_display()


func update_weight_display() -> void:
	if minimum_weight == 1 and maximum_weight == 6:
		$Indicator.hide()
	else:
		$Indicator.show()
		$Indicator.set_text(str(minimum_weight))


func set_pressed() -> void:
	$Sprite2D.texture = pressed_texture


func set_unpressed() -> void:
	$Sprite2D.texture = unpressed_texture


func _on_area_entered(area: Area2D) -> void:
	if $Sprite2D.texture == pressed_texture:
		return
	var face_value = area.get_top_face_value()
	if face_value >= minimum_weight and face_value <= maximum_weight:
		if get_node_or_null("Indicator") != null:
			$Indicator.hide()
		set_pressed()
		button_pressed.emit()
		$PressedSound.play()
