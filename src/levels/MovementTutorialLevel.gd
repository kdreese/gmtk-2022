class_name MovementTutorialLevel
extends Node2D


var nextLevel := "res://src/levels/MovementTestLevel.tscn"


func _ready() -> void:
	var error := $LevelEnd.connect("exit_reached_success", self, "_on_exit_reached_success")
	assert(not error)


func _on_exit_reached_success() -> void:
	Global.level_path = nextLevel
	var error := get_tree().reload_current_scene()
	assert(not error)
