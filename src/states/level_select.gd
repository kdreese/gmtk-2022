extends ColorRect


signal level_select_exited

const LevelSelectButton = preload("res://src/states/level_select_button.tscn")

var page_idx := 0


func _ready() -> void:
	create_menu()


func create_menu() -> void:
	# We will have at most 9 buttons.
	var num_buttons := mini(9, Global.NUM_LEVELS)
	for idx in range(num_buttons):
		var button := LevelSelectButton.instantiate()
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var error := button.connect("pressed", Callable(self, "_on_level_button_pressed").bind(idx))
		assert(not error)
		$G.add_child(button)

	if Global.NUM_LEVELS <= 9:
		$NextButton.hide()

	$PrevButton.hide()


func show_menu() -> void:
	page_idx = 0
	display()
	show()
	$G.get_child(0).grab_focus()


func display() -> void:
	var num_levels_to_show := mini(Global.NUM_LEVELS - 9 * page_idx, 9)
	for idx in range($G.get_child_count()):
		var button: Button = $G.get_child(idx)
		if idx < num_levels_to_show:
			var level_idx := 9 * page_idx + idx
			var texture: Texture2D
			if level_idx != 0 and Global.best_scores[level_idx - 1] < 0:
				button.disabled = true
				texture = load("res://assets/level_thumbnails/level_locked.png")
				button.find_child("Title").text = "???"
				button.find_child("PerfectScore").hide()
			else:
				button.disabled = false
				texture = load(Global.LEVELS[level_idx]["thumbnail"])
				button.find_child("Title").text = Global.LEVELS[level_idx]["name"]
				if Global.best_scores[level_idx] <= Global.LEVELS[level_idx]["perfect_score"] and Global.best_scores[level_idx] >= 0:
					button.find_child("PerfectScore").show()
				else:
					button.find_child("PerfectScore").hide()
			button.find_child("Thumbnail").texture = texture
			button.visible = true
		else:
			button.visible = false


func _on_level_button_pressed(idx: int) -> void:
	Global.current_level_idx = 9 * page_idx + idx
	if Global.current_level_idx == 0:
		Autosplitter.run_start()
	var error := get_tree().change_scene_to_file("res://src/states/game.tscn")
	assert(not error)


func _on_BackButton_pressed() -> void:
	hide()
	emit_signal("level_select_exited")


func _on_NextButton_pressed() -> void:
	page_idx += 1
	display()
	$PrevButton.show()
	if Global.NUM_LEVELS < (page_idx + 1) * 9:
		$NextButton.hide()
	$G.get_child(0).grab_focus()


func _on_PrevButton_pressed() -> void:
	page_idx -= 1
	display()
	$NextButton.show()
	if page_idx == 0:
		$PrevButton.hide()
	$G.get_child(0).grab_focus()
