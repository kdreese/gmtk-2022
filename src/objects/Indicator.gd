extends Node2D


const AMPLITUDE = 5
const FREQUENCY = 2.0

const INDICATOR_DEFAULT_STRING := "<default>"

export var indicator_string := INDICATOR_DEFAULT_STRING

var total_time := 0.0

onready var starting_position := position


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	total_time = -global_position.x / 120.0
	if indicator_string == INDICATOR_DEFAULT_STRING:
		indicator_string = generate_indicator_string()
	$CenterContainer/Label.text = indicator_string


func _process(delta: float) -> void:
	position = starting_position + Vector2(0.0, AMPLITUDE)*sin(total_time)
	total_time += (delta * FREQUENCY)


func generate_indicator_string() -> String:
	var button = get_parent()
	if button.minimum_weight == button.maximum_weight:
		return str(button.minimum_weight)
	elif button.maximum_weight == 6:
		return "%d+" % button.minimum_weight
	return "%d-%d" % [button.minimum_weight, button.maximum_weight]
