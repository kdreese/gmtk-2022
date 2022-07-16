extends CanvasLayer


var nextLevel


func _ready() -> void:
	$ColorRect.hide()


func update(continueTo) -> void:
	$ColorRect/C/V/Congratulations.text = "Congratulations!\nYou finished the level in %d moves!" % get_parent().moves
	nextLevel = continueTo


func _on_ContinueButton_pressed() -> void:
	get_tree().paused = false
	Global.level_path = nextLevel
	var error := get_tree().reload_current_scene()
	assert(not error)


func _on_RestartButton_pressed() -> void:
	get_tree().paused = false
	var error := get_tree().reload_current_scene()
	assert(not error)


func _on_ToMenuButton_pressed() -> void:
	get_tree().paused = false
	var error := get_tree().change_scene("res://src/states/Menu.tscn")
	assert(not error)
