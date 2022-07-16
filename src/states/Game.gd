extends Node2D


var level: Node2D


func _ready() -> void:
	level = load(Global.level_path).instance() as Node2D
	var tile_map := level.get_node("TileMap") as TileMap

	add_child(level)

	for coords in tile_map.get_used_cells():
		var tile := tile_map.get_cell(coords.x, coords.y)
		if tile_map.tile_set.tile_get_name(tile) == "Start":
			var player := preload("res://src/objects/Player.tscn").instance() as Node2D
			player.position = tile_map.map_to_world(coords)
			player.grid_coords = coords
			player.tile_map = tile_map
			level.add_child(player)
