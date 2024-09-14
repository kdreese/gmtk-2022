@tool
class_name TileSelectButton
extends Button


signal button_toggled(toggled_on: bool, button_idx: int)


@export var texture: Texture2D
@export var button_text: String
@export var button_idx: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%TextureRect.texture = texture
	%Label.text = button_text


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		%TextureRect.texture = texture
		%Label.text = button_text


func _toggled(toggled_on: bool) -> void:
	button_toggled.emit(toggled_on, button_idx)
