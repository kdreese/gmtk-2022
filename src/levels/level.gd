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

const CLASS_TO_SCENE : Dictionary = {
	LevelObject.BUTTON: preload("res://src/objects/level_button.tscn"),
	LevelObject.TOGGLE: preload("res://src/objects/toggle.tscn"),
	LevelObject.GATE: preload("res://src/objects/gate.tscn"),
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

## Onready vars (see post_init()):
## The tile map layer for ground tiles.
var ground_tile_map: TileMapLayer
## The preview layer for ground tiles.
var ground_preview_tile_map: TileMapLayer
## A reference to the wire tile map. Not guaranteed to exist.
var wire_tile_map: TileMapLayer
## The node that is the parent of all LevelObjects.
var objects: Node2D


## Load some common references.
## In order to be able to export level data from a PackedScene without having to add it to the tree,
## and thus hook up some references to LevelObjects, you can call this function. Basically it acts
## as a phony @onready decorator for tile_map, wire_tile_map, and objects.
func post_init() -> void:
	ground_tile_map = $TileMap.get_node("Ground")
	ground_preview_tile_map = $TileMap.get_node_or_null("GroundPreview")
	wire_tile_map = $TileMap.get_node_or_null("Wires")
	objects = $Objects


func _ready() -> void:
	post_init()


func handle_player_move(grid_coords: Vector2) -> void:
	for gate in get_tree().get_nodes_in_group("Gates"):
		gate.update_z_index(grid_coords)

func toggle_wire_net(index: int) -> void:
	invert_wires_3(level_wire_nets[index])
	for object in wire_sinks[index]:
		object.toggle()


func invert_wire(grid_coords: Vector2, on_bottom: bool = true) -> void:
	if wire_tile_map == null:
		return

	# Get the new tile index.
	var new_tile_idx: int
	var tile_idx := wire_tile_map.get_cell_source_id(grid_coords)
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
	var atlas_coords := wire_tile_map.get_cell_atlas_coords(grid_coords)
	var alternative_tile := wire_tile_map.get_cell_alternative_tile(grid_coords)
	wire_tile_map.set_cell(grid_coords, new_tile_idx, atlas_coords, alternative_tile)


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
	if wire_tile_map == null:
		return []

	var wire_tiles := wire_tile_map.get_used_cells() as Array[Vector2i]

	# To handle crosses, duplicate the tiles that are crossed.
	var cross_tiles: Array[int]= [CROSS_BOTH_OFF, CROSS_BOTH_ON, CROSS_BOTTOM_ON, CROSS_TOP_ON]
	var wires: Array[Vector3i] = []
	for wire_tile in wire_tiles:
		if wire_tile_map.get_cell_source_id(wire_tile) in cross_tiles:
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
			var source_id := wire_tile_map.get_cell_source_id(wire_tile)
			var alternative_tile := wire_tile_map.get_cell_alternative_tile(wire_tile)

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
				var next_tile := get_wire(wire_tile, direction)
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
func get_wire(coords: Vector2i, direction: Vector2i) -> Vector3i:
	var next_tile := coords + direction
	var cross_tiles := [CROSS_BOTH_OFF, CROSS_BOTH_ON, CROSS_BOTTOM_ON, CROSS_TOP_ON]
	if wire_tile_map.get_cell_source_id(next_tile) not in cross_tiles:
		return Vector3i(next_tile.x, next_tile.y, 0)
	else:
		var alternative_tile := wire_tile_map.get_cell_alternative_tile(next_tile)
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


## Save level data to a PackedByteArray
## This function returns an array. The first element is a bool that is true if the function was
## successful. If the value is true, then the second element in the array is the PackedByteArray
## containing the level data.
##
## If the first element of the array is false, the second element is a String containing the reason
## for the failure.
func save_level_data() -> Array:
	var output := PackedByteArray()
	# Allocate 6 bytes for the start coord, end coord, and max/min values.
	output.resize(6)
	var cursor := 0

	var start_tiles := ground_tile_map.get_used_cells_by_id(1) as Array[Vector2i]
	if len(start_tiles) == 0:
		return [false, "Level does not have a start tile."]
	if len(start_tiles) > 1:
		return [false, "Level has more than one start tile."]

	output.encode_s8(cursor, start_tiles[0].x)
	cursor += 1
	output.encode_s8(cursor, start_tiles[0].y)
	cursor += 1

	var level_ends := objects.get_children().filter(
		func is_level_end(x): return x.get_object_type() == LevelObject.LEVEL_END
	)
	if len(level_ends) == 0:
		return [false, "Level does not contain a finish tile."]
	elif len(level_ends) > 1:
		return [false, "Level has more than one finish tile."]

	var finish_tile := ground_tile_map.local_to_map(level_ends[0].position - level_ends[0].get_position_offset()) as Vector2i

	output.encode_s8(cursor, finish_tile.x)
	cursor += 1
	output.encode_s8(cursor, finish_tile.y)
	cursor += 1

	output.encode_s8(cursor, level_ends[0].minimum_weight)
	cursor += 1
	output.encode_s8(cursor, level_ends[0].maximum_weight)
	cursor += 1

	# Remove the level end from the objects to avoid processing it again later.
	objects.remove_child(level_ends[0])

	var normal_tiles := ground_tile_map.get_used_cells_by_id(0) as Array[Vector2i]
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
				var byte3 := wire_tile_map.get_cell_source_id(Vector2i(wire.x, wire.y))

				var alt_tile := wire_tile_map.get_cell_alternative_tile(Vector2i(wire.x, wire.y))
				byte3 |= (alt_tile & 0x3) << 4

				if wire.z:
					byte3 |= 0x80

				output.encode_u8(cursor + 2, byte3)
				cursor += 3

	var num_objects := objects.get_child_count()
	# 1 byte for length, 4 for each object (x, y, 2 for state)
	output.resize(output.size() + 1 + 4 * num_objects)

	output.encode_s8(cursor, objects.get_child_count())
	cursor += 1

	for object in objects.get_children() as Array[LevelObject]:
		var coords := ground_tile_map.local_to_map(object.position - object.get_position_offset()) as Vector2i
		output.encode_s8(cursor, object.get_object_type())
		output.encode_s8(cursor + 1, coords.x)
		output.encode_s8(cursor + 2, coords.y)
		match object.get_object_type():
			LevelObject.BUTTON:
				object = object as LevelButton
				var byte4 := object.minimum_weight as int
				byte4 |= (object.maximum_weight & 0xF) << 4
				output.encode_u8(cursor + 3, byte4)
			LevelObject.TOGGLE:
				object = object as Toggle
				var byte4 := object.minimum_weight as int
				byte4 |= (object.maximum_weight & 0xF) << 4
				output.encode_u8(cursor + 3, byte4)
			LevelObject.GATE:
				object = object as Gate
				output.encode_u8(cursor + 3, object.is_open)

		cursor += 4

	while output.size() % 3 != 0:
		output.push_back(0)

	return [true, output]


func place_tile(coords: Vector2i, is_preview: bool = false) -> void:
	var tile_map: TileMapLayer
	if is_preview:
		tile_map = ground_preview_tile_map
	else:
		tile_map = ground_tile_map

	tile_map.set_cell(coords, 0, Vector2i(0, 0))

	var tile_bl := coords + Vector2i(0, 1)
	# Check the surrounding tiles on the actual layer, even if this is a preview.
	if (ground_tile_map.get_cell_source_id(tile_bl) == 2
		and ground_tile_map.get_cell_atlas_coords(tile_bl) == Vector2i(2, 0)
		and ground_tile_map.get_cell_alternative_tile(tile_bl) == 0):
		tile_map.set_cell(tile_bl, 2, Vector2i(0, 0))
	elif ground_tile_map.get_cell_source_id(tile_bl) == -1:
		tile_map.set_cell(tile_bl, 2, Vector2i(2, 0), 1)

	var tile_br := coords + Vector2i(1, 0)
	if (ground_tile_map.get_cell_source_id(tile_br) == 2
		and ground_tile_map.get_cell_atlas_coords(tile_br) == Vector2i(2, 0)
		and ground_tile_map.get_cell_alternative_tile(tile_br) == 1):
		tile_map.set_cell(tile_br, 2, Vector2i(0, 0))
	elif ground_tile_map.get_cell_source_id(tile_br) == -1:
		tile_map.set_cell(tile_br, 2, Vector2i(2, 0), 0)


func remove_tile(coords: Vector2i) -> void:
	var tile_tl := coords + Vector2i(-1, 0)
	var tile_tr := coords + Vector2i(0, -1)
	if (ground_tile_map.get_cell_source_id(tile_tl) in [0, 1]
		and ground_tile_map.get_cell_source_id(tile_tr) in [0, 1]):
		ground_tile_map.set_cell(coords, 2, Vector2i(0, 0))
	elif ground_tile_map.get_cell_source_id(tile_tl) in [0, 1]:
		ground_tile_map.set_cell(coords, 2, Vector2i(2, 0), 0)
	elif ground_tile_map.get_cell_source_id(tile_tr) in [0, 1]:
		ground_tile_map.set_cell(coords, 2, Vector2i(2, 0), 1)
	else:
		ground_tile_map.set_cell(coords, -1)

	var tile_bl := coords + Vector2i(0, 1)
	if (ground_tile_map.get_cell_source_id(tile_bl) == 2
		and ground_tile_map.get_cell_atlas_coords(tile_bl) == Vector2i(2, 0)
		and ground_tile_map.get_cell_alternative_tile(tile_bl) == 1):
		ground_tile_map.set_cell(tile_bl, -1, Vector2i(0, 0))
	elif (ground_tile_map.get_cell_source_id(tile_bl) == 2
		  and ground_tile_map.get_cell_atlas_coords(tile_bl) == Vector2i(0, 0)):
		ground_tile_map.set_cell(tile_bl, 2, Vector2i(2, 0), 0)

	var tile_br := coords + Vector2i(1, 0)
	if (ground_tile_map.get_cell_source_id(tile_br) == 2
		and ground_tile_map.get_cell_atlas_coords(tile_br) == Vector2i(2, 0)
		and ground_tile_map.get_cell_alternative_tile(tile_br) == 0):
		ground_tile_map.set_cell(tile_br, -1, Vector2i(0, 0))
	elif (ground_tile_map.get_cell_source_id(tile_br) == 2
		  and ground_tile_map.get_cell_atlas_coords(tile_br) == Vector2i(0, 0)):
		ground_tile_map.set_cell(tile_br, 2, Vector2i(2, 0), 1)


func load_level_data(data: PackedByteArray) -> void:
	for layer in $TileMap.get_children():
		layer.clear()

	for child in objects.get_children():
		objects.remove_child(child)
		child.queue_free()

	# We need 6 bytes for the requied params.
	assert(data.size() >= 6)
	var cursor := 0

	var start_tile := Vector2i(data.decode_s8(cursor), data.decode_s8(cursor + 1))
	cursor += 2

	place_tile(start_tile)
	ground_tile_map.set_cell(start_tile, 1, Vector2i(0, 0))

	var end_tile := Vector2i(data.decode_s8(cursor), data.decode_s8(cursor + 1))
	cursor += 2

	place_tile(end_tile)
	var level_end := preload("res://src/objects/level_end.tscn").instantiate() as LevelEnd
	objects.add_child(level_end)
	level_end.position = ground_tile_map.map_to_local(end_tile) + level_end.get_position_offset()

	level_end.minimum_weight = data.decode_s8(cursor)
	cursor += 1
	level_end.maximum_weight = data.decode_s8(cursor)
	cursor += 1
	level_end.update_weight_display()

	var num_tiles := data.decode_s8(cursor)
	cursor += 1

	for _idx in range(num_tiles):
		var tile := Vector2i(data.decode_s8(cursor), data.decode_s8(cursor + 1))
		cursor += 2
		place_tile(tile)

	wire_sinks.clear()
	level_wire_nets.clear()

	if not wire_tile_map:
		return

	var num_nets := data.decode_s8(cursor)
	cursor += 1

	wire_tile_map = wire_tile_map as TileMapLayer
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

			wire_tile_map.set_cell(coords, source_id, Vector2i(0, 0), alt_tile)
			wire_net.append(Vector3i(coords.x, coords.y, wire_z))

		level_wire_nets.append(wire_net)
		wire_sinks.append([])

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

		var object = CLASS_TO_SCENE[type].instantiate() as LevelObject
		object.position = ground_tile_map.map_to_local(coords) + object.get_position_offset()
		match type:
			LevelObject.BUTTON:
				var button := object as LevelButton
				button.minimum_weight = state & 0xF
				button.maximum_weight = (state >> 4) & 0xF
				button.button_pressed.connect(toggle_wire_net.bind(net_idx))
			LevelObject.TOGGLE:
				var toggle := object as Toggle
				toggle.minimum_weight = state & 0xF
				toggle.maximum_weight = (state >> 4) & 0xF
				toggle.toggled.connect(toggle_wire_net.bind(net_idx))
			LevelObject.GATE:
				var gate := object as Gate
				# Gates delete the tile under them if they're closed.
				place_tile(coords)
				gate.tile_map = ground_tile_map
				gate.is_open = bool(state)
				wire_sinks[net_idx].append(gate)
		objects.add_child(object)
