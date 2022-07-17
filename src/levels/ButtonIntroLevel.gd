extends Level


func _ready() -> void:
	var error := $LevelButton.connect("button_pressed", self, "_on_button_pressed", [$LevelButton])
	assert(not error)


func handle_player_move():
	$Gate.update_z_index(get_node("Player").grid_coords)


func _on_button_pressed(instance: LevelButton) -> void:
	if instance.name == "LevelButton":
		$Gate.open()
