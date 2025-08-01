extends TileMapLayer
class_name BoardTileMapLayer

@export var env_map : EnvTerrainMapping
@export var object : Node
# reference for non-existent tile position
static var NULL_TILE = Vector2i(-1,-1)
var TILE_SIZE : float

@export var BOARD_SCALE : float = 0.1

var _border_dim
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Update the positioning of the tilemaps
	scale = Vector2(BOARD_SCALE, BOARD_SCALE)
	tile_set = env_map.tileset
	TILE_SIZE = tile_set.tile_size.x * BOARD_SCALE

func _set_up(parent : Node, border_dim : Vector2i) -> void:
	_border_dim = border_dim
	object = parent

func get_local_centre_of_tile(coords : Vector2i) -> Vector2:
	if coords == NULL_TILE:
		return coords
	var local_pos = Vector2((coords.x + 0.5) * TILE_SIZE, (coords.y + 0.5) * TILE_SIZE)
	return local_pos
	
func get_mouse_tile_pos() -> Vector2i:
	return local_to_map(get_local_mouse_position())

func tilemap_to_matrix(tilemap_pos : Vector2i) -> Vector2i:
	return tilemap_pos - _border_dim 

func matrix_to_tilepos(matrix_pos : Vector2i) -> Vector2i:
	return _border_dim + matrix_pos
