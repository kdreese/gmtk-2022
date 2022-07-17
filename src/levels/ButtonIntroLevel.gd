extends Level


var tiles := [
	Vector2(13, 0),
	Vector2(13, 1),
	Vector2(13, 2),
	Vector2(13, 3),
	Vector2(13, 4),
	Vector2(14, 0),
]


func handle_player_move():
	$Gate.update_z_index(get_node("Player").grid_coords)


func _on_LevelButton_button_pressed() -> void:
	$Gate.open()
	invert_wires(tiles)
