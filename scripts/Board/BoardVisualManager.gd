extends TileMapLayer
class_name BoardVisualManager

@export var proc_gen : BoardProcGenerator
@export var env_map : EnvTerrainMapping
@export var darken_tilemap : TileMapLayer
@export var object : Node

# reference for non-existent tile position
static var NULL_TILE = Vector2i(-1,-1)
var TILE_SIZE : float

var colouration : int = 0
# Length/Width (no. cells) of board
@export var BOARD_SCALE : float = 0.1
var player_id : int = 0
var board_layout : Vector2i = Vector2i(2,2)

func set_up(board_size : Vector2i = Vector2i(8,8), board_num : Vector2i = Vector2i(1,1), border_width : Vector2i = Vector2i(0,0)) -> void:
	proc_gen.set_up(board_size, board_num, border_width)
	for i in range(4):
		#if player_id == i:
		#	colouration = 0
		#	proc_gen.generate_board(create_terrain_tile,place_building_on_tile, i)
		#else:
			colouration = 0
			proc_gen.generate_board(create_terrain_tile, place_building_on_tile, i)
	
	colouration = 4 
	proc_gen.generate_border(create_terrain_tile,place_fake_building)


func _ready() -> void:
	# Update the positioning of the tilemaps
	scale = Vector2(BOARD_SCALE, BOARD_SCALE)
	darken_tilemap.scale = Vector2(BOARD_SCALE, BOARD_SCALE)
	z_index = -1
	tile_set = env_map.tileset
	TILE_SIZE = tile_set.tile_size.x * BOARD_SCALE
	darken_tilemap.tile_set = env_map.tileset

func create_terrain_tile(terrain : EnvTerrain, tile_pos : Vector2i) -> void:
	var darken_tile = colouration
	
	# Every alternate tile, set the alternate colour in the tilemap
	if (tile_pos.x + tile_pos.y) % 2 == 1:
		darken_tile = colouration + 1
	
	set_cell(tile_pos, 0, env_map.getTilePosbyEnv(terrain), darken_tile)
	darken_tilemap.set_cell(tile_pos, 1, Vector2(0,0), 0)

# try to place placeable on tile
# Private function
func place_building_on_tile(data: BuildingData, tile_pos : Vector2i) -> void:
	if data != null:
		var building : Building = Building.new_building_frm_data(data)
		object.add_child(building)
		building.z_index = tile_pos.y
		building.position = get_local_centre_of_tile(tile_pos)
		building.get_node("JiggleAnimation").play("jiggle")
	# MUST TRIGGER BEFORE ADDING (otherwise places self on board then can score against itself)
	#board_matrix.add_placeable_to_tile(tile_pos, placeable)

func place_fake_building(data: BuildingData, tile_pos : Vector2i) -> void:
	if data != null:
		var fake_building : Sprite2D = Sprite2D.new()
		fake_building.set_texture(data.building_sprite)
		fake_building.set_modulate(Color.DIM_GRAY)
		object.add_child(fake_building)
		fake_building.z_index = tile_pos.y
		fake_building.position = get_local_centre_of_tile(tile_pos)

func get_local_centre_of_tile(coords : Vector2i) -> Vector2:
	if coords == NULL_TILE:
		return coords
	var local_pos = Vector2((coords.x + 0.5) * TILE_SIZE, (coords.y + 0.5) * TILE_SIZE)
	return local_pos

#func get_global_tile_pos(coords : Vector2i) -> Vector2:
	#if coords == NULL_TILE:
		#return coords
	#return to_global(get_local_centre_of_tile(coords))
	
func unshade_area(start_coords : Vector2i, end_coords : Vector2i) -> void:
	for x in range(start_coords.x, end_coords.x + 1):
		for y in range(start_coords.y, end_coords.y + 1):
			darken_tilemap.erase_cell(Vector2i(x,y))

func shade_area(start_coords : Vector2i, end_coords : Vector2i) -> void:
	for x in range(start_coords.x, end_coords.x + 1):
		for y in range(start_coords.y, end_coords.y + 1):
			darken_tilemap.set_cell(Vector2i(x,y), 1, Vector2(0,0), 0)
