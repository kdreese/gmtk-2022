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
		button.pressed.connect(self._on_level_button_pressed.bind(idx))
		$G.add_child(button)


func show_menu() -> void:
	page_idx = 0
	display()
	show()
	$G.get_child(0).grab_focus()

	$PrevButton.hide()
	if Global.NUM_LEVELS <= 9:
		$NextButton.hide()
	else:
		$NextButton.show()


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
				var level := Global.LEVELS[level_idx].instantiate()
				texture = load(level.thumbnail)
				button.find_child("Title").text = level.level_name
				if Global.best_scores[level_idx] <= level.perfect_score and Global.best_scores[level_idx] >= 0:
					button.find_child("PerfectScore").show()
				else:
					button.find_child("PerfectScore").hide()
				level.queue_free()
			button.find_child("Thumbnail").texture = texture
			button.visible = true
		else:
			button.visible = false


func _on_level_button_pressed(idx: int) -> void:
	Global.current_level_idx = 9 * page_idx + idx
	var game := preload("res://src/states/game.tscn").instantiate() as Game
	get_tree().root.add_child(game)
	get_tree().set_current_scene(game)
	get_tree().root.remove_child(self.owner)
	game.play_single_level(Global.current_level_idx)


func _on_BackButton_pressed() -> void:
	hide()
	level_select_exited.emit()


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
