extends Level


func _ready() -> void:
	var error := $LevelButton.connect("button_pressed", self, "_on_button_pressed", [$LevelButton])
	assert(not error)
	error = $LevelButton2.connect("button_pressed", self, "_on_button_pressed", [$LevelButton2])
	assert(not error)
	error = $LevelButton3.connect("button_pressed", self, "_on_button_pressed", [$LevelButton3])
	assert(not error)

func handle_player_move():
	for gate in [$Gate, $Gate2, $Gate3, $Gate4, $Gate5]:
		gate.update_z_index(get_node("Player").grid_coords)

func _on_button_pressed(instance: LevelButton) -> void:
	if instance.name == "LevelButton":
		$Gate.open()
		$Gate2.open()
	elif instance.name == "LevelButton2":
		$Gate3.open()
		$Gate4.open()
	elif instance.name == "LevelButton3":
		$Gate5.open()
