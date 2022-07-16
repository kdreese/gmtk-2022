class_name LevelButton
extends Node2D


signal button_pressed

var unpressed_texture = preload("res://assets/objects/button.png")
var pressed_texture = preload("res://assets/objects/button_pressed.png")

export var minimum_weight: int = 1
export var maximum_weight: int = 6

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the initial state to unpressed.
	$Sprite.texture = unpressed_texture


func set_pressed() -> void:
	$Sprite.texture = pressed_texture


func set_unpressed() -> void:
	$Sprite.texture = unpressed_texture


func _on_area_entered(area: Area2D) -> void:
	var face_value = area.get_top_face_value()
	if face_value >= minimum_weight and face_value <= maximum_weight:
		set_pressed()
		emit_signal("button_pressed")
