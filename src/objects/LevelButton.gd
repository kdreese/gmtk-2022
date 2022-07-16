class_name LevelButton
extends Node2D


var unpressed_texture = preload("res://assets/objects/button.png")
var pressed_texture = preload("res://assets/objects/button_pressed.png")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the initial state to unpressed.
	$Sprite.texture = unpressed_texture


func set_pressed() -> void:
	$Sprite.texture = pressed_texture


func set_unpressed() -> void:
	$Sprite.texture = unpressed_texture
