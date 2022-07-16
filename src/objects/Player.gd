class_name Player
extends Node2D


enum FaceState {FACE_1, FACE_2_1, FACE_2_2, FACE_3_1, FACE_3_2, FACE_4, FACE_5, FACE_6_1, FACE_6_2}

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
	setAnim()


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("move_forward"):
		rotateX()
	elif Input.is_action_just_pressed("move_back"):
		for _i in range(3):
			rotateX()
	elif Input.is_action_just_pressed("move_right"):
		rotateZ()
	elif Input.is_action_just_pressed("move_left"):
		for _i in range(3):
			rotateZ()


# Get the rotated version of the given face.
func rotatedFace(state: int) -> int:
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
func rotateX() -> void:
	# The side and backside faces are rotated.
	side_face = rotatedFace(side_face)
	backside_face = rotatedFace(backside_face)
	# The rest of the faces fall into a cycle
	var temp: int = top_face
	top_face = front_face
	front_face = bottom_face
	bottom_face = back_face
	back_face = temp
	# Set the animation
	setAnim()


# Rotate the die clockwise about the Y axis, which is normal to the top face.
func rotateY() -> void:
	# The top and bottom faces are rotated.
	top_face = rotatedFace(top_face)
	bottom_face = rotatedFace(bottom_face)
	# Because of the way the pictures are structured, this is no longer a simple cycle.
	var temp: int = front_face
	front_face = rotatedFace(side_face)
	side_face = rotatedFace(back_face)
	back_face = rotatedFace(backside_face)
	backside_face = rotatedFace(temp)
	setAnim()


# Rotate the die clockwise about the Z axis, which is normal to the front face.
func rotateZ() -> void:
	# The front and back faces are rotated.
	front_face = rotatedFace(front_face)
	back_face = rotatedFace(back_face)
	# The rest of the faces fall into a cycle.
	var temp: int = top_face
	top_face = backside_face
	backside_face = bottom_face
	bottom_face = side_face
	side_face = temp
	# Set the animations.
	setAnim()


# Set the animation to match the current orienation.
func setAnim() -> void:
	setFaceAnim($FrontFace, front_face)
	setFaceAnim($SideFace, side_face)
	setFaceAnim($TopFace, top_face)


# Set the animation state for a single face.
func setFaceAnim(face: AnimatedSprite, state: int) -> void:
	if state == FaceState.FACE_1:
		face.play("1")
	elif state == FaceState.FACE_2_1:
		face.play("2_1")
	elif state == FaceState.FACE_2_2:
		face.play("2_2")
	elif state == FaceState.FACE_3_1:
		face.play("3_1")
	elif state == FaceState.FACE_3_2:
		face.play("3_2")
	elif state == FaceState.FACE_4:
		face.play("4")
	elif state == FaceState.FACE_5:
		face.play("5")
	elif state == FaceState.FACE_6_1:
		face.play("6_1")
	elif state == FaceState.FACE_6_2:
		face.play("6_2")
	else:
		print("Invalid state (%d) passed to setAnim()." % state)
