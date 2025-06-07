extends TileMapLayer
class_name BoardTileMapLayer

@export var env_map : EnvTerrainMapping
@export var object : Node
var fake_colouration : Color
# reference for non-existent tile position
static var NULL_TILE = Vector2i(-1,-1)
var TILE_SIZE : float


# Length/Width (no. cells) of board
@export var BOARD_SCALE : float = 0.1
var board_layout : Vector2i = Vector2i(2,2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Update the positioning of the tilemaps
	scale = Vector2(BOARD_SCALE, BOARD_SCALE)
	tile_set = env_map.tileset
	TILE_SIZE = tile_set.tile_size.x * BOARD_SCALE
	
func place_fake_placeable(data: PlaceableData, tile_pos : Vector2i) -> void:
	if data != null:
		var fake_placeable : Sprite2D = Sprite2D.new()
		fake_placeable.set_texture(data.building_sprite)
		fake_placeable.set_modulate(fake_colouration)
		object.add_child(fake_placeable)
		fake_placeable.z_index = tile_pos.y
		fake_placeable.position = get_local_centre_of_tile(tile_pos)

func get_local_centre_of_tile(coords : Vector2i) -> Vector2:
	if coords == NULL_TILE:
		return coords
	var local_pos = Vector2((coords.x + 0.5) * TILE_SIZE, (coords.y + 0.5) * TILE_SIZE)
	return local_pos
