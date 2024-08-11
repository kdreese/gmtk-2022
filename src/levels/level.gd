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
	CROSS_BOTH_ON,
	CROSS_BOTH_OFF,
	SPUR_ON,
	SPUR_OFF,
	ELBOW_DOWN_OFF,
	ELBOW_DOWN_ON,
}

enum {
	LEVEL_BUTTON = 0,
	TOGGLE,
	GATE
}

const CLASS_TO_SCENE : Dictionary = {
	LEVEL_BUTTON: preload("res://src/objects/level_button.tscn"),
	TOGGLE: preload("res://src/objects/toggle.tscn"),
	GATE: preload("res://src/objects/gate.tscn"),
}

@export
var level_name: String = ""

@export_multiline
var text: String = ""

@export
var perfect_score: int = 0

@export_file("*.png")
var thumbnail: String = ""

## Array of arrays representing the wires for a single net.
var level_wire_nets: Array = []
## Array of arrays representing the objects controlled by each wire net.
var wire_sinks: Array = []


func _ready() -> void:
	var data := save_level_data()
	print(len(data), len(Utils.b64_encode(data)))
	print(Utils.b64_encode(data))
	load_level_data(data)


func handle_player_move(grid_coords: Vector2) -> void:
	for gate in get_tree().get_nodes_in_group("Gates"):
		gate.update_z_index(grid_coords)

func toggle_wire_net(index: int) -> void:
	invert_wires_3(level_wire_nets[index])
	for object in wire_sinks[index]:
		object.toggle()


func invert_wire(grid_coords: Vector2, on_bottom: bool = true) -> void:
	var wire_tile_map = get_node("WireTileMap") as TileMap
	if wire_tile_map == null:
		return

	# Get the new tile index.
	var new_tile_idx: int
	var tile_idx := wire_tile_map.get_cell_source_id(0, grid_coords)
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
	var atlas_coords := wire_tile_map.get_cell_atlas_coords(0, grid_coords)
	var alternative_tile := wire_tile_map.get_cell_alternative_tile(0, grid_coords)
	wire_tile_map.set_cell(0, grid_coords, new_tile_idx, atlas_coords, alternative_tile)


func invert_wires(coords_list: Array) -> void:
	for coords in coords_list:
		invert_wire(coords)


func invert_wires_3(coords_list: Array) -> void:
	for coords in coords_list:
		invert_wire(Vector2(coords.x, coords.y), coords.z)

## Get a list of all wire groups in the level.
##
## This will return a list of lists. Each sub-list corresponds to a single grouping of wire tiles.
func get_wires() -> Array:
	if not get_node_or_null("WireTileMap"):
		return []

	var wire_tile_map := get_node("WireTileMap") as TileMap

	var wire_tiles := wire_tile_map.get_used_cells(0) as Array[Vector2i]

	# To handle crosses, duplicate the tiles that are crossed.
	var cross_tiles: Array[int]= [CROSS_BOTH_OFF, CROSS_BOTH_ON, CROSS_BOTTOM_ON, CROSS_TOP_ON]
	var wires: Array[Vector3i] = []
	for wire_tile in wire_tiles:
		if wire_tile_map.get_cell_source_id(0, wire_tile) in cross_tiles:
			wires.append(Vector3i(wire_tile.x, wire_tile.y, 0))
			wires.append(Vector3i(wire_tile.x, wire_tile.y, 1))
		else:
			wires.append(Vector3i(wire_tile.x, wire_tile.y, 0))

	var nets: Array = []
	while len(wires) > 0:
		var net: Array[Vector3i] = []
		var tiles_to_search: Array[Vector3i] = [wires.pop_front()]
		while len(tiles_to_search) > 0:
			var wire := tiles_to_search.pop_front() as Vector3i
			var wire_tile := Vector2i(wire.x, wire.y)
			var wire_layer := wire.z
			net.append(wire)
			var source_id := wire_tile_map.get_cell_source_id(0, wire_tile)
			var alternative_tile := wire_tile_map.get_cell_alternative_tile(0, wire_tile)

			var directions: Array[Vector2i] = []

			if source_id in [X_OFF, X_ON]:
				directions.push_back(Vector2i.DOWN)
				directions.push_back(Vector2i.RIGHT)
				directions.push_back(Vector2i.LEFT)
				directions.push_back(Vector2i.UP)
			elif source_id in [T_OFF, T_ON]:
				if alternative_tile == 0:
					directions.push_back(Vector2i.DOWN)
					directions.push_back(Vector2i.LEFT)
					directions.push_back(Vector2i.UP)
				elif alternative_tile == 1:
					directions.push_back(Vector2i.RIGHT)
					directions.push_back(Vector2i.LEFT)
					directions.push_back(Vector2i.UP)
				elif alternative_tile == 2:
					directions.push_back(Vector2i.LEFT)
					directions.push_back(Vector2i.DOWN)
					directions.push_back(Vector2i.RIGHT)
				else:
					directions.push_back(Vector2i.UP)
					directions.push_back(Vector2i.DOWN)
					directions.push_back(Vector2i.RIGHT)
			elif source_id in [STRAIGHT_OFF, STRAIGHT_ON]:
				if alternative_tile == 0:
					directions.push_back(Vector2i.DOWN)
					directions.push_back(Vector2i.UP)
				else:
					directions.push_back(Vector2i.LEFT)
					directions.push_back(Vector2i.RIGHT)
			elif source_id in [ELBOW_SIDE_OFF, ELBOW_SIDE_ON]:
				if alternative_tile == 0:
					directions.push_back(Vector2i.DOWN)
					directions.push_back(Vector2i.LEFT)
				else:
					directions.push_back(Vector2i.UP)
					directions.push_back(Vector2i.RIGHT)
			elif source_id in cross_tiles:
				if wire_layer == alternative_tile:
					directions.push_back(Vector2i.DOWN)
					directions.push_back(Vector2i.UP)
				else:
					directions.push_back(Vector2i.LEFT)
					directions.push_back(Vector2i.RIGHT)
			elif source_id in [SPUR_OFF, SPUR_ON]:
				if alternative_tile == 0:
					directions.push_back(Vector2i.DOWN)
				elif alternative_tile == 1:
					directions.push_back(Vector2i.RIGHT)
				elif alternative_tile == 2:
					directions.push_back(Vector2i.LEFT)
				else:
					directions.push_back(Vector2i.UP)
			elif source_id in [ELBOW_DOWN_OFF, ELBOW_DOWN_ON]:
				if alternative_tile == 0:
					directions.push_back(Vector2i.DOWN)
					directions.push_back(Vector2i.RIGHT)
				else:
					directions.push_back(Vector2i.UP)
					directions.push_back(Vector2i.LEFT)
			else:
				push_error("Invalid wire tile map source ID %d." % source_id)

			for direction in directions:
				var next_tile := get_wire(wire_tile_map, wire_tile, direction)
				if next_tile not in net and next_tile not in tiles_to_search:
					var index := wires.find(next_tile)
					if index != -1:
						wires.remove_at(index)
					tiles_to_search.append(next_tile)

		nets.append(net)

	return nets

## Gets the coordinates for the wire that makes a connection with this tile.
##
## This is only needed for cross tiles, as we need to make sure we only select the right part of
## the cross.
func get_wire(wire_tile_map: TileMap, coords: Vector2i, direction: Vector2i) -> Vector3i:
	var next_tile := coords + direction
	var cross_tiles := [CROSS_BOTH_OFF, CROSS_BOTH_ON, CROSS_BOTTOM_ON, CROSS_TOP_ON]
	if wire_tile_map.get_cell_source_id(0, next_tile) not in cross_tiles:
		return Vector3i(next_tile.x, next_tile.y, 0)
	else:
		var alternative_tile := wire_tile_map.get_cell_alternative_tile(0, next_tile)
		match direction:
			Vector2i.RIGHT:
				return Vector3i(next_tile.x, next_tile.y, 0 if alternative_tile else 1)
			Vector2i.DOWN:
				return Vector3i(next_tile.x, next_tile.y, 1 if alternative_tile else 0)
			Vector2i.LEFT:
				return Vector3i(next_tile.x, next_tile.y, 0 if alternative_tile else 1)
			Vector2i.UP:
				return Vector3i(next_tile.x, next_tile.y, 1 if alternative_tile else 0)
			_:
				push_error("Invalid direction passed in to get_wire.")
				return Vector3i()


func save_level_data() -> PackedByteArray:
	var output := PackedByteArray()
	# Allocate 6 bytes for the start coord, end coord, and max/min values.
	output.resize(6)
	var cursor := 0

	var start_tiles := $TileMap.get_used_cells_by_id(0, 1) as Array[Vector2i]
	if len(start_tiles) > 1:
		push_error("Level has more than one start tile.")
		return PackedByteArray()

	output.encode_s8(cursor, start_tiles[0].x)
	cursor += 1
	output.encode_s8(cursor, start_tiles[0].y)
	cursor += 1

	var finish_tile := $TileMap.local_to_map($LevelEnd.position + Vector2(0, 16)) as Vector2i

	output.encode_s8(cursor, finish_tile.x)
	cursor += 1
	output.encode_s8(cursor, finish_tile.y)
	cursor += 1

	output.encode_s8(cursor, $LevelEnd.minimum_weight)
	cursor += 1
	output.encode_s8(cursor, $LevelEnd.maximum_weight)
	cursor += 1

	var normal_tiles := $TileMap.get_used_cells_by_id(0, 0) as Array[Vector2i]
	# The finish tile always has a normal tile underneath it.
	normal_tiles.remove_at(normal_tiles.find(finish_tile))

	output.resize(output.size() + 1 + 2 * len(normal_tiles))
	output.encode_s8(cursor, len(normal_tiles))
	cursor += 1

	for tile in normal_tiles:
		output.encode_s8(cursor, tile.x)
		cursor += 1
		output.encode_s8(cursor, tile.y)
		cursor += 1

	var wire_nets := get_wires()

	# A bit inefficient but we don't know how much to allocate right away.
	output.resize(output.size() + 1)
	output.encode_s8(cursor, len(wire_nets))
	cursor += 1

	if len(wire_nets) > 0:
		var wire_tile_map: TileMap = $WireTileMap
		for wire_net in wire_nets:
			# 1 byte for the net length, 3 for each wire.
			output.resize(output.size() + 1 + 3 * len(wire_net))
			output.encode_s8(cursor, len(wire_net))
			cursor += 1
			for wire in wire_net as Array[Vector3i]:
				output.encode_s8(cursor, wire.x)
				output.encode_s8(cursor + 1, wire.y)

				# The third byte can encode the source_id, alternative_tile and whether the net is on
				# the top or bottom.
				var byte3 := wire_tile_map.get_cell_source_id(0, Vector2i(wire.x, wire.y))

				var alt_tile := wire_tile_map.get_cell_alternative_tile(0, Vector2i(wire.x, wire.y))
				byte3 |= (alt_tile & 0x3) << 4

				if wire.z:
					byte3 |= 0x80

				output.encode_u8(cursor + 2, byte3)
				cursor += 3

	var num_objects := $Objects.get_child_count()
	# 1 byte for length, 4 for each object (x, y, 2 for state)
	output.resize(output.size() + 1 + 4 * num_objects)

	output.encode_s8(cursor, $Objects.get_child_count())
	cursor += 1

	for object in $Objects.get_children() as Array[Node]:
		match object.get_object_type():
			"LevelButton":
				object = object as LevelButton
				var coords := $TileMap.local_to_map(object.position) as Vector2i
				output.encode_s8(cursor, LEVEL_BUTTON)
				output.encode_s8(cursor + 1, coords.x)
				output.encode_s8(cursor + 2, coords.y)
				var byte4 := object.minimum_weight as int
				byte4 |= (object.maximum_weight & 0xF) << 4
				output.encode_u8(cursor + 3, byte4)
			"Toggle":
				object = object as Toggle
				var coords := $TileMap.local_to_map(object.position) as Vector2i
				output.encode_s8(cursor, TOGGLE)
				output.encode_s8(cursor + 1, coords.x)
				output.encode_s8(cursor + 2, coords.y)
				var byte4 := object.minimum_weight as int
				byte4 |= (object.maximum_weight & 0xF) << 4
				output.encode_u8(cursor + 3, byte4)
			"Gate":
				object = object as Gate
				var coords := $TileMap.local_to_map(object.position + Vector2(0, 8)) as Vector2i
				output.encode_s8(cursor, GATE)
				output.encode_s8(cursor + 1, coords.x)
				output.encode_s8(cursor + 2, coords.y)
				output.encode_u8(cursor + 3, object.is_open)

		cursor += 4

	while output.size() % 3 != 0:
		output.push_back(0)

	return output


func place_tile(coords: Vector2i) -> void:
	$TileMap.set_cell(0, coords, 0, Vector2i(0, 0))

	var tile_bl := coords + Vector2i(0, 1)
	if $TileMap.get_cell_source_id(0, tile_bl) == 2:
		$TileMap.set_cell(0, tile_bl, 2, Vector2i(0, 0))
	elif $TileMap.get_cell_source_id(0, tile_bl) == -1:
		$TileMap.set_cell(0, tile_bl, 2, Vector2i(2, 0), 1)

	var tile_br := coords + Vector2i(1, 0)
	if $TileMap.get_cell_source_id(0, tile_br) == 2:
		$TileMap.set_cell(0, tile_br, 2, Vector2i(0, 0))
	elif $TileMap.get_cell_source_id(0, tile_br) == -1:
		$TileMap.set_cell(0, tile_br, 2, Vector2i(2, 0), 0)


func load_level_data(data: PackedByteArray) -> void:
	$TileMap.clear()
	# We need 6 bytes for the requied params.
	assert(data.size() >= 6)
	var cursor := 0

	var start_tile := Vector2i(data.decode_s8(cursor), data.decode_s8(cursor + 1))
	cursor += 2

	place_tile(start_tile)
	$TileMap.set_cell(0, start_tile, 1, Vector2i(0, 0))

	var end_tile := Vector2i(data.decode_s8(cursor), data.decode_s8(cursor + 1))
	cursor += 2

	place_tile(end_tile)
	$LevelEnd.position = $TileMap.map_to_local(end_tile) - Vector2(0, 16)

	$LevelEnd.minimum_weight = data.decode_s8(cursor)
	cursor += 1
	$LevelEnd.maximum_weight = data.decode_s8(cursor)
	cursor += 1

	var num_tiles := data.decode_s8(cursor)
	cursor += 1

	for _idx in range(num_tiles):
		var tile := Vector2i(data.decode_s8(cursor), data.decode_s8(cursor + 1))
		cursor += 2
		place_tile(tile)

	wire_sinks.clear()
	level_wire_nets.clear()

	var wire_tile_map := get_node_or_null("WireTileMap")
	if not wire_tile_map:
		return

	var num_nets := data.decode_s8(cursor)
	cursor += 1

	wire_tile_map = wire_tile_map as TileMap
	wire_tile_map.clear()
	for _idx in num_nets:
		var num_wires := data.decode_s8(cursor)
		cursor += 1

		var wire_net: Array[Vector3i] = []
		for _idx2 in num_wires:
			var coords := Vector2i(data.decode_s8(cursor), data.decode_s8(cursor + 1))
			var byte3 := data.decode_u8(cursor + 2)
			cursor += 3

			var source_id := byte3 & 0xF
			var alt_tile := (byte3 & 0x30) >> 4
			var wire_z = 1 if (byte3 & 0x80) else 0

			wire_tile_map.set_cell(0, coords, source_id, Vector2i(0, 0), alt_tile)
			wire_net.append(Vector3i(coords.x, coords.y, wire_z))

		level_wire_nets.append(wire_net)
		wire_sinks.append([])

	for object in $Objects.get_children():
		$Objects.remove_child(object)
		object.queue_free()

	var num_objects = data.decode_s8(cursor)
	cursor += 1

	for _idx in num_objects:
		var type := data.decode_s8(cursor)
		var coords := Vector2i(data.decode_s8(cursor + 1), data.decode_s8(cursor + 2))
		var state := data.decode_u8(cursor + 3)
		cursor += 4
		var net_idx := -1
		for idx in range(len(level_wire_nets)):
			for tile in level_wire_nets[idx]:
				if Vector2i(tile.x, tile.y) == coords:
					net_idx = idx

		if net_idx == -1:
			push_error("Object not connected to a wire net. (coords = %d, %d)" % [coords.x, coords.y])
			continue

		match type:
			LEVEL_BUTTON:
				var button := CLASS_TO_SCENE[LEVEL_BUTTON].instantiate()
				button.position = $TileMap.map_to_local(coords)
				button.minimum_weight = state & 0xF
				button.maximum_weight = (state >> 4) & 0xF
				button.button_pressed.connect(toggle_wire_net.bind(net_idx))
				$Objects.add_child(button)
			TOGGLE:
				var toggle := CLASS_TO_SCENE[TOGGLE].instantiate()
				toggle.position = $TileMap.map_to_local(coords)
				toggle.minimum_weight = state & 0xF
				toggle.maximum_weight = (state >> 4) & 0xF
				toggle.toggled.connect(toggle_wire_net.bind(net_idx))
				$Objects.add_child(toggle)
			GATE:
				var gate := CLASS_TO_SCENE[GATE].instantiate()
				gate.position = $TileMap.map_to_local(coords) - Vector2(0, 8)
				# Gates delete the tile under them if they're closed.
				place_tile(coords)
				gate.is_open = bool(state)
				wire_sinks[net_idx].append(gate)
				$Objects.add_child(gate)

