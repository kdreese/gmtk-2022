class_name MovementTutorialLevel
extends Node2D


var nextLevel := "res://src/levels/MovementTestLevel.tscn"


func _ready() -> void:
	var error := $LevelEnd.connect("exit_reached_success", self, "_on_exit_reached_success")
	assert(not error)


func _on_exit_reached_success() -> void:
	get_tree().paused = true
	get_node("../LevelComplete").update(nextLevel)
	get_node("../LevelComplete/ColorRect").show()
