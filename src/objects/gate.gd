class_name Gate
extends LevelObject


var tile_map: TileMap = null
var grid_coords: Vector2

@export var is_open: bool


func get_object_type() -> int:
	return GATE


func get_position_offset() -> Vector2:
	return Vector2(0, -8)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if tile_map == null:
		push_error("TileMap not set for gate '%s'" % name)
		return

	update_animation_speed()

	grid_coords = tile_map.local_to_map(position)
	if is_open:
		$AnimatedSprite2D.play("opened")
		var base_source_id := Global.find_source_id_by_name(tile_map.tile_set, "Base")
		tile_map.set_cell(0, grid_coords, base_source_id, Vector2i.ZERO)
	else:
		$AnimatedSprite2D.play("closed")
		tile_map.set_cell(0, grid_coords, -1)




func update_animation_speed() -> void:
	# Use quadratic to make it feel smoother.
	$AnimatedSprite2D.speed_scale = (0.5 * pow(float(Global.animation_speed), 2.0)) + 0.5


func update_z_index(player_position: Vector2):
	if not is_open:
		if player_position.x > grid_coords.x or player_position.y > grid_coords.y:
			z_index = 1
		else:
			z_index = 3
	else:
		z_index = 1


func open() -> void:
	if is_open:
		return
	$AnimatedSprite2D.play("open")
	var base_source_id := Global.find_source_id_by_name(tile_map.tile_set, "Base")
	tile_map.set_cell(0, grid_coords, base_source_id, Vector2i.ZERO)
	is_open = true
	while $AnimatedSprite2D.frame <= 4:
		await $AnimatedSprite2D.frame_changed
	z_index = 1


func close() -> void:
	if not is_open:
		return
	$AnimatedSprite2D.play("close")
	tile_map.set_cell(0, grid_coords, -1)
	is_open = false


func toggle() -> void:
	if not is_open:
		open()
	else:
		close()

