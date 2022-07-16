class_name ButtonIntroLevel
extends Node2D


func _ready() -> void:
	var error := $LevelButton.connect("button_pressed", self, "_on_button_pressed", [$LevelButton])
	assert(not error)


func _on_button_pressed(instance: LevelButton) -> void:
	if instance.name == "LevelButton":
		$TileMap.set_cell(14, 4, $TileMap.tile_set.find_tile_by_name("GateOpen"))
