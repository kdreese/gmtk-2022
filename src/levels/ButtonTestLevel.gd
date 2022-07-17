class_name ButtonTestLevel
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
		$Gate.open()
		$Gate2.open()
	elif instance.name == "LevelButton2":
		$Gate2.open()
		$Gate4.open()
	elif instance.name == "LevelButton3":
		$Gate5.open()
