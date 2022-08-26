extends Node2D


var tile_map: TileMap
var grid_coords: Vector2

export var is_open: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tile_map = get_parent().get_node("TileMap")
	grid_coords = tile_map.world_to_map(position)
	if is_open:
		$AnimatedSprite.play("opened")
		tile_map.set_cellv(grid_coords, tile_map.tile_set.find_tile_by_name("Base"))
	else:
		$AnimatedSprite.play("closed")
		tile_map.set_cellv(grid_coords, -1)


func open() -> void:
	if is_open:
		return
	$AnimatedSprite.play("open")
	tile_map.set_cellv(grid_coords, tile_map.tile_set.find_tile_by_name("Base"))
	is_open = true


func close() -> void:
	if not is_open:
		return
	$AnimatedSprite.play("close")
	tile_map.set_cellv(grid_coords, -1)
	is_open = false


func toggle() -> void:
	if not is_open:
		open()
	else:
		close()

