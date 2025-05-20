extends Node2D
class_name Board

@onready
var highlight_map : TileMapLayer = $"./Highlights"

# TerrainDisplay vs TerrainActual https://www.youtube.com/watch?v=jEWFSv3ivTg
@onready
var env_map : TileMapLayer = $"./TerrainActual"



# Contains a 2d Matrix of tile data
var board_matrix

# reference for non-existent tile position
static var NULL_TILE = Vector2i(-1,-1)

# Length/Width (no. cells) of board
@export var BOARD_SIZE : int = 5
@export var BOARD_SCALE : float = 0.13 

# Position of where the board is created on screen
@export var offset = Vector2(200,100)
var board_coord : Array[Vector2] #pair of coords, top left corner and bottom right corner

@export var proc_gen : ProceduralGenerator = preload("res://Resources/ProcGen/DummyProcGen.tres")
var proc_gen_offset : Vector2i = Vector2i(0,0)

@export var environment : EnvTerrainMapping = preload("res://Resources/EnvTerrain/TestEnvTerrainMapping.tres")

func _ready() -> void:
	# Update the positioning of the tilemaps
	env_map.scale = Vector2(BOARD_SCALE, BOARD_SCALE)
	env_map.position = to_local(offset)
	env_map.z_index = -1
	env_map.tile_set = environment.tileset

	highlight_map.scale = Vector2(BOARD_SCALE, BOARD_SCALE)
	highlight_map.position = to_local(offset)
	highlight_map.tile_set = environment.tileset
	
	board_coord = [offset, offset + env_map.tile_set.tile_size * (BOARD_SIZE) * BOARD_SCALE] 
	
	proc_gen.generate_world()
	initialise_matrix()

# Initialize 2d array matrix
func initialise_matrix() -> void:
	board_matrix = Array()
	board_matrix.resize(BOARD_SIZE)
	for i in range(BOARD_SIZE):
		board_matrix[i] = Array()
		board_matrix[i].resize(BOARD_SIZE)
		for j in range(BOARD_SIZE): 
			board_matrix[i][j] = spawn_tile(i, j)

func spawn_tile(i, j) -> BoardTile:	
	# To achieve the alternative darkened tiles: 
	# Shaders
	# https://www.youtube.com/watch?v=eYlBociPwdw
	# Or alternative tiles in the tilemap with modulation?
	var id : String = proc_gen.(i,j) 
	env_map.set_cell(Vector2(i,j), 0, environment.getTilebyId(id), 0)
	return BoardTile.new(environment.getTileDatabyId(id), get_global_tile_pos(Vector2i(i,j)))

func get_tile(coord : Vector2i) -> BoardTile:
	return board_matrix[coord.x][coord.y]

func get_global_tile_pos(coords : Vector2i) -> Vector2:
	if coords == NULL_TILE:
		return coords
	var tile_length : float = env_map.tile_set.tile_size.x * BOARD_SCALE
	var local_pos = Vector2((coords.x + 0.5) * tile_length, (coords.y + 0.5) * tile_length)
	return local_pos + offset

func mouse_near_board() -> bool:
	var mouse_pos = get_local_mouse_position()
	const THRESHOLD = 150
	if mouse_pos.x > board_coord[0].x - THRESHOLD and mouse_pos.x < board_coord[1].x + THRESHOLD:
		return mouse_pos.y > board_coord[0].y - THRESHOLD and mouse_pos.y < board_coord[1].y + THRESHOLD
	return false
	
func get_mouse_tile_pos() -> Vector2i:
	var mouse_pos = get_local_mouse_position()
	var tile_mouse_pos = env_map.local_to_map((mouse_pos - offset) * 1.0/BOARD_SCALE)  
	if tile_mouse_pos.x >= 0 && tile_mouse_pos.x < BOARD_SIZE && tile_mouse_pos.y >= 0 && tile_mouse_pos.y < BOARD_SIZE:
		return tile_mouse_pos
	else:
		return NULL_TILE


func place_on_tile(tile_pos : Vector2i, placeable: Placeable):
	var tile_data = board_matrix[tile_pos.x][tile_pos.y]
	if placeable is Building:
		tile_data.add_building(placeable)

	elif placeable is EnvTerrain:
		tile_data.change_terrain = placeable
		env_map.set_cell(tile_pos, 0, environment.getTilebyId(placeable.tile_name), 0)
		
func snap_mouse_to_tile_pos() -> Vector2:
	return get_global_tile_pos(get_mouse_tile_pos())

# try to place building on tile or swap terrain
func place_building_on_tile(tile_pos : Vector2i, building: Building) -> bool:
	var tile_data : BoardTile = board_matrix[tile_pos.x][tile_pos.y]
	return tile_data.stack_if_able(building)
	#if placeable is Building:
		#
	#elif placeable is EnvTerrain:
		#tile_data.change_terrain(placeable)
		#env_map.set_cell(tile_pos, 0, environment.getTilebyId(placeable.tile_name), 0)
		#return true

# Returns true if Placeable is successfully placed, else returns false
func place_on_board_if_able(building: Building) -> bool:
	var tile_mouse_pos : Vector2i = get_mouse_tile_pos()
	if tile_mouse_pos != NULL_TILE:
		return place_building_on_tile(tile_mouse_pos, building)
	return false
	
func get_global_length() -> int:
	return board_coord[1].x - board_coord[0].x 

func constrain_pattern_to_board(pattern_arr : Array, tile_pos : Vector2i) -> Array[Vector2i] :
	var out_arr : Array[Vector2i] = []
	for relative_tile in pattern_arr:
		var true_tile = Vector2i(relative_tile[0], relative_tile[1]) + tile_pos
		if true_tile == true_tile.clampi(0, BOARD_SIZE - 1):
			out_arr.push_back(true_tile)
	return out_arr

# highlight affected tiles if building were to be placed
# TODO: display cutey point totals above each tile
func preview_placement(try_building : Building, tile_pos : Vector2i) -> void :
	reset_preview()
	var affected_tiles = constrain_pattern_to_board(try_building.AOE, tile_pos)
	for highlight_tile_pos in affected_tiles:
		highlight_map.set_cell(highlight_tile_pos,2, Vector2i(0,0),0)
	pass

func reset_preview() -> void :
	for i in range(BOARD_SIZE):
		for j in range(BOARD_SIZE): 
			highlight_map.set_cell(Vector2(i,j), -1, Vector2i(0,0), 0)
	pass

#sets buildings in proper place and draw order
func redraw() -> void :
	pass

