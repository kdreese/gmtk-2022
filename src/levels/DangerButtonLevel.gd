class_name DangerButtonLevel
extends Node2D


func _ready() -> void:
	var error := $LevelButton.connect("button_pressed", self, "_on_button_pressed", [$LevelButton])
	assert(not error)
	error = $LevelButton2.connect("button_pressed", self, "_on_button_pressed", [$LevelButton2])
	assert(not error)
	error = $LevelButton3.connect("button_pressed", self, "_on_button_pressed", [$LevelButton3])
	assert(not error)


func _on_button_pressed(instance: LevelButton) -> void:
	if instance.name == "LevelButton":
		$TileMap.set_cell(12, -1, $TileMap.tile_set.find_tile_by_name("GateOpen"))
	if instance.name == "LevelButton2":
		$TileMap.set_cell(12, -2, $TileMap.tile_set.find_tile_by_name("GateClosed"))
	if instance.name == "LevelButton3":
		$TileMap.set_cell(12, -3, $TileMap.tile_set.find_tile_by_name("GateOpen"))
