class_name Player
extends Node2D


signal player_moved


enum FaceState {FACE_1, FACE_2_1, FACE_2_2, FACE_3_1, FACE_3_2, FACE_4, FACE_5, FACE_6_1, FACE_6_2}

const PALETTES := [
	preload("res://resouces/palettes/1.tres"),
	preload("res://resouces/palettes/2_1.tres"),
	preload("res://resouces/palettes/2_2.tres"),
	preload("res://resouces/palettes/3_1.tres"),
	preload("res://resouces/palettes/3_2.tres"),
	preload("res://resouces/palettes/4.tres"),
	preload("res://resouces/palettes/5.tres"),
	preload("res://resouces/palettes/6_1.tres"),
	preload("res://resouces/palettes/6_2.tres"),
]


var top_face: int
var side_face: int
var front_face: int
var bottom_face: int
var back_face: int
var backside_face: int

var grid_coords := Vector2.ZERO
var tile_map: TileMap


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize the state of the die to be 1 facing up, with 2 and 3 visible.
	top_face = FaceState.FACE_1
	front_face = FaceState.FACE_2_1
	side_face = FaceState.FACE_3_1
	backside_face = FaceState.FACE_4
	back_face = FaceState.FACE_5
	bottom_face = FaceState.FACE_6_1
	update_animation_speed()
	update_palettes()
	set_anim("idle")


func _physics_process(_delta: float) -> void:
	if $FrontFace.animation == "idle":
		if Input.is_action_pressed("move_forward"):
			if move(Vector2(0, -1)):
				$ExtraFace.material.get_shader_param("palette").gradient = PALETTES[bottom_face]
				set_anim("rotate_x")
		elif Input.is_action_pressed("move_back"):
			if move(Vector2(0, 1)):
				$ExtraFace.material.get_shader_param("palette").gradient = PALETTES[back_face]
				set_anim("rotate_neg_x")
		elif Input.is_action_pressed("move_right"):
			if move(Vector2(1, 0)):
				$ExtraFace.material.get_shader_param("palette").gradient = PALETTES[backside_face]
				set_anim("rotate_z")
		elif Input.is_action_pressed("move_left"):
			if move(Vector2(-1, 0)):
				$ExtraFace.material.get_shader_param("palette").gradient = PALETTES[bottom_face]
				set_anim("rotate_neg_z")


func update_animation_speed() -> void:
	var new_speed := float(Global.animation_speed) * 2.0
	if new_speed == 2.0:
		new_speed = 3.0
	elif new_speed == 0.0:
		new_speed = 2.0
	$FrontFace.speed_scale = new_speed
	$SideFace.speed_scale = new_speed
	$TopFace.speed_scale = new_speed
	$ExtraFace.speed_scale = new_speed


func get_top_face_value() -> int:
	if top_face == FaceState.FACE_1:
		return 1
	elif top_face == FaceState.FACE_2_1:
		return 2
	elif top_face == FaceState.FACE_2_2:
		return 2
	elif top_face == FaceState.FACE_3_1:
		return 3
	elif top_face == FaceState.FACE_3_2:
		return 3
	elif top_face == FaceState.FACE_4:
		return 4
	elif top_face == FaceState.FACE_5:
		return 5
	elif top_face == FaceState.FACE_6_1:
		return 6
	elif top_face == FaceState.FACE_6_2:
		return 6
	else:
		print("Invalid face... how?")
		assert(false)
		return 0


func update_palettes() -> void:
	$FrontFace.material.get_shader_param("palette").gradient = PALETTES[front_face]
	$SideFace.material.get_shader_param("palette").gradient = PALETTES[side_face]
	$TopFace.material.get_shader_param("palette").gradient = PALETTES[top_face]


# Move the die one space
func move(offset: Vector2) -> bool:
	var new_coords := grid_coords + offset
	if is_movable(new_coords):
		grid_coords = new_coords
		emit_signal("player_moved")
		return true
	return false


# Check if the space attempting to be moved into is capable of being moved into
func is_movable(coord: Vector2) -> bool:
	var tile := tile_map.get_cellv(coord)
	if tile == -1 or tile == tile_map.tile_set.find_tile_by_name("GateClosed"):
		return false
	return true


# Get the rotated version of the given face.
func rotated_face(state: int) -> int:
	if state == FaceState.FACE_2_1:
		return FaceState.FACE_2_2
	elif state == FaceState.FACE_2_2:
		return FaceState.FACE_2_1
	elif state == FaceState.FACE_3_1:
		return FaceState.FACE_3_2
	elif state == FaceState.FACE_3_2:
		return FaceState.FACE_3_1
	elif state == FaceState.FACE_6_1:
		return FaceState.FACE_6_2
	elif state == FaceState.FACE_6_2:
		return FaceState.FACE_6_1
	else:
		# 1, 4, and 5, are rotationally symmetric
		return state


# Rotate the die clockwise about the X axis, which is normal to the side face.
func rotate_x() -> void:
	# The side and backside faces are rotated.
	side_face = rotated_face(side_face)
	backside_face = rotated_face(backside_face)
	# The rest of the faces fall into a cycle
	var temp: int = top_face
	top_face = front_face
	front_face = bottom_face
	bottom_face = back_face
	back_face = temp


# Rotate the die counter-clockwise about the X axis, which is normal to the side face.
func rotate_neg_x() -> void:
	# The side and backside faces are rotated.
	side_face = rotated_face(side_face)
	backside_face = rotated_face(backside_face)
	# The rest of the faces fall into a cycle
	var temp: int = top_face
	top_face = back_face
	back_face = bottom_face
	bottom_face = front_face
	front_face = temp


# TODO: re-write. As of now this is deprecated.
# Rotate the die clockwise about the Y axis, which is normal to the top face.
func rotate_y() -> void:
	# The top and bottom faces are rotated.
	top_face = rotated_face(top_face)
	bottom_face = rotated_face(bottom_face)
	# Because of the way the pictures are structured, this is no longer a simple cycle.
	var temp: int = front_face
	front_face = rotated_face(side_face)
	side_face = rotated_face(back_face)
	back_face = rotated_face(backside_face)
	backside_face = rotated_face(temp)


# Rotate the die clockwise about the Z axis, which is normal to the front face.
func rotate_z() -> void:
	# The front and back faces are rotated.
	front_face = rotated_face(front_face)
	back_face = rotated_face(back_face)
	# The rest of the faces fall into a cycle.
	var temp: int = top_face
	top_face = backside_face
	backside_face = bottom_face
	bottom_face = side_face
	side_face = temp


# Rotate the die counter-clockwise about the Z axis, which is normal to the front face.
func rotate_neg_z() -> void:
	# The front and back faces are rotated.
	front_face = rotated_face(front_face)
	back_face = rotated_face(back_face)
	# The rest of the faces fall into a cycle.
	var temp: int = top_face
	top_face = side_face
	side_face = bottom_face
	bottom_face = backside_face
	backside_face = temp


func set_anim(animation: String) -> void:
	$FrontFace.play(animation)
	$SideFace.play(animation)
	$TopFace.play(animation)
	$ExtraFace.play(animation)


func _on_animation_finished() -> void:
	if $FrontFace.animation == "idle":
		return
	elif $FrontFace.animation == "rotate_x":
		rotate_x()
	elif $FrontFace.animation == "rotate_neg_x":
		rotate_neg_x()
	elif $FrontFace.animation == "rotate_z":
		rotate_z()
	elif $FrontFace.animation == "rotate_neg_z":
		rotate_neg_z()
	$FrontFace.play("idle")
	$TopFace.play("idle")
	$SideFace.play("idle")
	$ExtraFace.play("idle")
	update_palettes()
	position = tile_map.map_to_world(grid_coords)
	$MoveSound.play()
