class_name ButtonIntroLevel
extends Node2D


var nextLevel := "res://src/levels/ButtonTestLevel.tscn"


func _ready() -> void:
	var error := $LevelButton.connect("button_pressed", self, "_on_button_pressed", [$LevelButton])
	assert(not error)
	error = $LevelEnd.connect("exit_reached_success", self, "_on_exit_reached_success")
	assert(not error)


func _on_button_pressed(instance: LevelButton) -> void:
	if instance.name == "LevelButton":
		$TileMap.set_cell(14, 4, $TileMap.tile_set.find_tile_by_name("GateOpen"))


func _on_exit_reached_success() -> void:
	Global.level_path = nextLevel
	var error := get_tree().reload_current_scene()
	assert(not error)
