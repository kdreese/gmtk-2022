class_name LevelObject
extends Node2D

enum {
	LEVEL_END,
	BUTTON,
	TOGGLE,
	GATE
}


@export_range(1, 6) var minimum_weight := 1
@export_range(1, 6) var maximum_weight := 6


func get_object_type() -> int:
	push_error("Function not implemented.")
	return -1


func get_position_offset() -> Vector2:
	push_error("Function not implemented.")
	return Vector2.ZERO


func get_grid_position(tile_map: TileMapLayer) -> Vector2i:
	var tile_center_position := position - get_position_offset()
	return tile_map.local_to_map(tile_center_position)


func update_weight_display() -> void:
	push_error("Function not implemented")
