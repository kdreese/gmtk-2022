@tool
class_name TileSelectButton
extends Button

@export var texture: Texture2D
@export var button_text: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%TextureRect.texture = texture
	%Label.text = button_text

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		%TextureRect.texture = texture
		%Label.text = button_text
