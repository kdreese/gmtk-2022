class_name LevelButton
extends Area2D


signal button_pressed

var unpressed_texture = preload("res://assets/objects/button.png")
var pressed_texture = preload("res://assets/objects/button_pressed.png")

@export var minimum_weight: int = 1
@export var maximum_weight: int = 6


func _ready() -> void:
	# Set the initial state to unpressed.
	$Sprite2D.texture = unpressed_texture
	if minimum_weight == 1 and maximum_weight == 6:
		$Indicator.queue_free()


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
			$Indicator.queue_free()
		set_pressed()
		emit_signal("button_pressed")
		$PressedSound.play()
