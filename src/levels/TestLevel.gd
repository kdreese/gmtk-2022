extends Level


func _ready() -> void:
	var error := $LevelButton.connect("button_pressed", self, "_on_button_pressed", [$LevelButton])
	assert(not error)
	$Gate2.open()


func handle_player_move():
	for gate in [$Gate, $Gate2]:
		gate.update_z_index(get_node("Player").grid_coords)


func _on_LevelButton_button_pressed() -> void:
	$Gate.open()
	$Gate2.close()
