extends Node2D


var level: Node2D

var moves: int

func _ready() -> void:
	level = load(Global.level_path).instance() as Node2D
	var tile_map := level.get_node("TileMap") as TileMap

	add_child(level)

	for coords in tile_map.get_used_cells():
		var tile := tile_map.get_cell(coords.x, coords.y)
		if tile_map.tile_set.tile_get_name(tile) == "Start":
			var player := preload("res://src/objects/Player.tscn").instance() as Node2D
			player.connect("player_moved", self, "_on_player_move")
			player.position = tile_map.map_to_world(coords)
			player.grid_coords = coords
			player.tile_map = tile_map
			level.add_child(player)

	reset_move_counter()


func update_move_counter() -> void:
	$UI/MoveCounter.text = "Moves: %d" % moves

func reset_move_counter() -> void:
	moves = 0
	update_move_counter()

func _on_player_move():
	moves += 1
	update_move_counter()
