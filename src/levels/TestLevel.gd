class_name TestLevel
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
		$TileMap.set_cell(32, 4, $TileMap.tile_set.find_tile_by_name("GateOpen"))
		$TileMap.set_cell(32, 5, $TileMap.tile_set.find_tile_by_name("GateOpen"))
	elif instance.name == "LevelButton2":
		$TileMap.set_cell(34, 4, $TileMap.tile_set.find_tile_by_name("GateOpen"))
		$TileMap.set_cell(34, 5, $TileMap.tile_set.find_tile_by_name("GateOpen"))
	elif instance.name == "LevelButton3":
		$TileMap.set_cell(36, 4, $TileMap.tile_set.find_tile_by_name("GateOpen"))
		$TileMap.set_cell(36, 5, $TileMap.tile_set.find_tile_by_name("GateOpen"))
