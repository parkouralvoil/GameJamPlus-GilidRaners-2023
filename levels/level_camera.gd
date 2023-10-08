extends Camera2D

@export var tilemap: TileMap

@onready var player: Player = null

# note, this is just for testing camera borders
func _ready():
	var map_rect = tilemap.get_used_rect()
	var tile_size = tilemap.cell_quadrant_size
	var world_size_in_pixels = map_rect.size * tile_size
#	limit_left = 0 + tile_size
#	limit_right = world_size_in_pixels.x + tile_size
#	limit_top = 0 + tile_size
#	limit_bottom = world_size_in_pixels.y + tile_size

func _process(delta):
	if player != null:
		position = player.position
