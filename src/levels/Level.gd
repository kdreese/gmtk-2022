class_name Level
extends Node2D


enum {
	X_ON = 0,
	X_OFF,
	T_ON,
	T_OFF,
	STRAIGHT_ON,
	STRAIGHT_OFF,
	ELBOW_SIDE_ON,
	ELBOW_SIDE_OFF,
	CROSS_TOP_ON,
	CROSS_BOTTOM_ON,
	CROSS_BOTH_ON
	CROSS_BOTH_OFF
	SPUR_ON
	SPUR_OFF
	ELBOW_DOWN_OFF,
	ELBOW_DOWN_ON
}


func invert_wire(grid_coords: Vector2, on_bottom: bool = true) -> void:
	var wire_tile_map = get_node("WireTileMap") as TileMap
	if wire_tile_map == null:
		return

	# Get the new tile index.
	var new_tile_idx
	var tile_idx = wire_tile_map.get_cellv(grid_coords)
	if tile_idx == -1:
		return
	elif tile_idx == X_ON:
		new_tile_idx = X_OFF
	elif tile_idx == X_OFF:
		new_tile_idx = X_ON
	elif tile_idx == T_ON:
		new_tile_idx = T_OFF
	elif tile_idx == T_OFF:
		new_tile_idx = T_ON
	elif tile_idx == X_OFF:
		new_tile_idx = X_ON
	elif tile_idx == STRAIGHT_ON:
		new_tile_idx = STRAIGHT_OFF
	elif tile_idx == STRAIGHT_OFF:
		new_tile_idx = STRAIGHT_ON
	elif tile_idx == ELBOW_SIDE_ON:
		new_tile_idx = ELBOW_SIDE_OFF
	elif tile_idx == ELBOW_SIDE_OFF:
		new_tile_idx = ELBOW_SIDE_ON
	elif tile_idx == CROSS_TOP_ON:
		if on_bottom:
			new_tile_idx = CROSS_BOTH_ON
		else:
			new_tile_idx = CROSS_BOTH_OFF
	elif tile_idx == CROSS_BOTTOM_ON:
		if on_bottom:
			new_tile_idx = CROSS_BOTH_OFF
		else:
			new_tile_idx = CROSS_BOTH_ON
	elif tile_idx == CROSS_BOTH_ON:
		if on_bottom:
			new_tile_idx = CROSS_TOP_ON
		else:
			new_tile_idx = CROSS_BOTTOM_ON
	elif tile_idx == CROSS_BOTH_OFF:
		if on_bottom:
			new_tile_idx = CROSS_BOTTOM_ON
		else:
			new_tile_idx = CROSS_TOP_ON
	elif tile_idx == SPUR_ON:
		new_tile_idx = SPUR_OFF
	elif tile_idx == SPUR_OFF:
		new_tile_idx = SPUR_ON
	elif tile_idx == ELBOW_DOWN_OFF:
		new_tile_idx = ELBOW_DOWN_ON
	elif tile_idx == ELBOW_DOWN_ON:
		new_tile_idx = ELBOW_DOWN_OFF
	else:
		return

	# Set the cell.
	var flip_x = wire_tile_map.is_cell_x_flipped(grid_coords.x, grid_coords.y)
	var flip_y = wire_tile_map.is_cell_y_flipped(grid_coords.x, grid_coords.y)
	var transpose = wire_tile_map.is_cell_transposed(grid_coords.x, grid_coords.y)
	wire_tile_map.set_cellv(grid_coords, new_tile_idx, flip_x, flip_y, transpose)


func invert_wires(coords_list: Array) -> void:
	for coords in coords_list:
		invert_wire(coords)


func invert_wires_3(coords_list: Array) -> void:
	for coords in coords_list:
		invert_wire(Vector2(coords.x, coords.y), coords.z)
