extends CanvasLayer


signal level_select_exited

var level_names := []
var level_paths := []
var buttons := []

var page_idx := 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hide this node, to start.
	$ColorRect.hide()


func load_levels() -> void:
	# Get a list of all the levels.
	var level_path = Global.FIRST_LEVEL_PATH
	while level_path != "":
		var level = load(level_path).instance()
		var level_end = level.get_node("LevelEnd") as LevelEnd
		level_names.push_back(level_end.level_name)
		level_paths.push_back(level_path)
		level_path = level_end.next_level_path

	# We will have at most 9 buttons.
	var num_buttons = min(9, len(level_names))
	for idx in range(num_buttons):
		var button = Button.new()
		button.rect_min_size = Vector2(120, 90)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var error = button.connect("pressed", self, "_on_level_button_pressed", [idx])
		assert(not error)
		$ColorRect/G.add_child(button)
		buttons.push_back(button)

	if len(level_names) <= 9:
		$ColorRect/NextButton.hide()

	$ColorRect/PrevButton.hide()


func display() -> void:
	var num_levels_to_show = min(len(level_names) - (9 * page_idx), 9)
	for idx in range(len(buttons)):
		if idx < num_levels_to_show:
			buttons[idx].text = level_names[9 * page_idx + idx]
			buttons[idx].visible = true
		else:
			buttons[idx].visible = false


func _on_level_button_pressed(idx: int) -> void:
	Global.level_path = level_paths[9 * page_idx + idx]
	var error := get_tree().change_scene("res://src/states/Game.tscn")
	assert(not error)


func _on_BackButton_pressed() -> void:
	$ColorRect.hide()
	emit_signal("level_select_exited")


func _on_NextButton_pressed() -> void:
	page_idx += 1
	display()
	$ColorRect/PrevButton.show()
	if len(level_names) < (page_idx + 1) * 9:
		$ColorRect/NextButton.hide()


func _on_PrevButton_pressed() -> void:
	page_idx -= 1
	display()
	$ColorRect/NextButton.show()
	if page_idx == 0:
		$ColorRect/PrevButton.hide()
