extends Node2D

gates := [Vector2(9, 0)]

func _ready() -> void:
	var error := $LevelButton.connect("button_pressed", self, "_on_button_pressed", [$LevelButton])
	assert(not error)



func calc_z_index() -> void:
	var player = get_parent().get_node("Player") as Player
	var grid_coords = player.grid_coords
	for gate in gates:
		if player.x > gate.x or player.y > gate.y:
			$TileMap.


func _on_LevelButton_button_pressed() -> void:
	$TileMap.set_cell(9, 0, $TileMap.tile_set.find_tile_by_name("GateOpen"))
	$TileMap.set_cell(13, 0, $TileMap.tile_set.find_tile_by_name("GateClosed"))
