extends ColorRect


signal level_select_exited

var page_idx := 0


func _ready() -> void:
	create_menu()


func create_menu() -> void:
	# We will have at most 9 buttons.
	var num_buttons := min(9, Global.NUM_LEVELS)
	for idx in range(num_buttons):
		var button := Button.new()
		button.rect_min_size = Vector2(120, 90)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var error := button.connect("pressed", self, "_on_level_button_pressed", [idx])
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
	var num_levels_to_show := min(Global.NUM_LEVELS - 9 * page_idx, 9)
	for idx in range($G.get_child_count()):
		var button: Button = $G.get_child(idx)
		if idx < num_levels_to_show:
			button.text = Global.LEVELS[9 * page_idx + idx]["name"]
			button.visible = true
		else:
			button.visible = false


func _on_level_button_pressed(idx: int) -> void:
	Global.current_level_idx = 9 * page_idx + idx
	var error := get_tree().change_scene("res://src/states/Game.tscn")
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
