class_name TestLevel
extends Node2D


func _ready() -> void:
	$LevelButton.connect("button_pressed", self, "_on_button_pressed", [$LevelButton])
	$LevelButton2.connect("button_pressed", self, "_on_button_pressed", [$LevelButton2])
	$LevelButton3.connect("button_pressed", self, "_on_button_pressed", [$LevelButton3])


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
