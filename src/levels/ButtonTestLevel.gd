class_name ButtonTestLevel
extends Node2D

var nextLevel := "res://src/levels/ButtonTestLevel.tscn"


func _ready() -> void:
	var error := $LevelButton.connect("button_pressed", self, "_on_button_pressed", [$LevelButton])
	assert(not error)
	error = $LevelButton2.connect("button_pressed", self, "_on_button_pressed", [$LevelButton2])
	assert(not error)
	error = $LevelButton3.connect("button_pressed", self, "_on_button_pressed", [$LevelButton3])
	assert(not error)
	error = $LevelEnd.connect("exit_reached_success", self, "_on_exit_reached_success")
	assert(not error)


func _on_button_pressed(instance: LevelButton) -> void:
	if instance.name == "LevelButton":
		$TileMap.set_cell(11, 2, $TileMap.tile_set.find_tile_by_name("GateOpen"))
		$TileMap.set_cell(11, 3, $TileMap.tile_set.find_tile_by_name("GateOpen"))
	elif instance.name == "LevelButton2":
		$TileMap.set_cell(13, 2, $TileMap.tile_set.find_tile_by_name("GateOpen"))
		$TileMap.set_cell(13, 3, $TileMap.tile_set.find_tile_by_name("GateOpen"))
	elif instance.name == "LevelButton3":
		$TileMap.set_cell(15, 2, $TileMap.tile_set.find_tile_by_name("GateOpen"))
		$TileMap.set_cell(15, 3, $TileMap.tile_set.find_tile_by_name("GateOpen"))


func _on_exit_reached_success() -> void:
	get_tree().paused = true
	get_node("../LevelComplete").update(nextLevel)
	get_node("../LevelComplete/ColorRect").show()
