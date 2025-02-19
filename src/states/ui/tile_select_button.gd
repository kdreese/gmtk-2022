@tool
class_name TileSelectButton
extends Button


signal button_toggled(toggled_on: bool, button_idx: int)


const TOOLTIP_DELAY := 0.25


@export var texture: Texture2D
@export var button_text: String
@export var button_idx: int


var mouse_inside := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%TextureRect.texture = texture
	%TooltipLabel.text = button_text


#func _process(_delta: float) -> void:
	#if Engine.is_editor_hint():
		#%TextureRect.texture = texture
		#%TooltipLabel.text = button_text


func _toggled(toggled_on: bool) -> void:
	button_toggled.emit(toggled_on, button_idx)


func on_mouse_enter() -> void:
	mouse_inside = true
	var timer := get_tree().create_timer(TOOLTIP_DELAY)
	timer.timeout.connect(on_timer_timeout)


func on_timer_timeout() -> void:
	if mouse_inside:
		# Place the tooltip centered above tht button
		%Tooltip.position.y = -(%Tooltip.size.y)
		%Tooltip.position.x = 0.5 * (size.x - %Tooltip.size.x)
		%Tooltip.show()


func on_mouse_exit() -> void:
	mouse_inside = false
	%Tooltip.hide()
