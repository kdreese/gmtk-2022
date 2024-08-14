class_name LevelObject
extends Node2D

enum {
	LEVEL_END,
	BUTTON,
	TOGGLE,
	GATE
}


func get_object_type() -> int:
	push_error("Function not implemented.")
	return -1


func get_position_offset() -> Vector2:
	push_error("Function not implemented.")
	return Vector2.ZERO
