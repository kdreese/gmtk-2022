extends Node2D


var tile_map: TileMap
var grid_coords: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tile_map = get_parent().get_node("TileMap")
	grid_coords = tile_map.world_to_map(position)


func update_z_index(player_position: Vector2):
	if $AnimatedSprite.animation == "closed":
		if player_position.x > grid_coords.x or player_position.y > grid_coords.y:
			z_index = 1
		else:
			z_index = 3
	else:
		z_index = 1


func open() -> void:
	$AnimatedSprite.play("open")
	$AnimatedSprite.offset.x += 16
	tile_map.set_cellv(grid_coords, tile_map.tile_set.find_tile_by_name("Base"))


func	 close() -> void:
	$AnimatedSprite.play("closed")
	$AnimatedSprite.offset -= 16
	tile_map.set_cellv(grid_coords, -1)
