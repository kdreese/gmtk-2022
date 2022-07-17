extends Level


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Gate4.open()


func handle_player_move() -> void:
	for gate in [$Gate, $Gate2, $Gate3, $Gate4]:
		gate.update_z_index(get_node("Player").grid_coords)


func _on_LevelButton_button_pressed() -> void:
	$Gate3.open()


func _on_LevelButton2_button_pressed() -> void:
	$Gate4.close()
	$Gate2.open()


func _on_LevelButton3_button_pressed() -> void:
	$Gate.open()
