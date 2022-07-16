extends Node2D


var starting_position: Vector2

const AMPLITUDE = 5
const FREQUENCY = 2.0
var total_time = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	starting_position = position
	total_time = -global_position.x / 120.0
	pass

func _process(delta: float) -> void:
	position = starting_position + Vector2(0.0, AMPLITUDE)*sin(total_time)
	total_time += (delta * FREQUENCY)

func hide() -> void:
	$CenterContainer.hide()
	$Sprite.hide()
