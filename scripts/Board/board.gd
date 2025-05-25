extends Node2D
class_name Board

@onready
var highlight_map : TileMapLayer = $"./Highlights"
# TerrainDisplay vs TerrainActual https://www.youtube.com/watch?v=jEWFSv3ivTg

@onready 
var env_map : TileMapLayer = $"./TerrainActual"

# Contains a 2d Matrix of BoardTiles
var board_matrix

# Every board is uniquely associated with a player
var board_id = 0

# reference for non-existent tile position
static var NULL_TILE = Vector2i(-1,-1)

# Length/Width (no. cells) of board
@export var BOARD_SIZE : int = 6
@export var BOARD_SCALE : float = 0.1
@export var TILE_SIZE : float

# Position of where the board is created on screen
var board_coord : Array[Vector2] #pair of coords, top left corner and bottom right corner

@export var proc_gen : ProceduralGenerator = preload("res://Resources/ProcGen/DummyProcGen.tres")
var proc_gen_offset : Vector2i = Vector2i(0,0)
 
# Contains the terrain_id -> terrain tileset mapping
@export var environment : EnvTerrainMapping = preload("res://Resources/EnvTerrain/TestEnvTerrainMapping.tres")

#################### FOR INIT ##################################


# makes hovering on and off reset relevant tiles only and not the whole board
var affected_tiles : Array[Vector2i] = []

# allows for scoring
@onready
var player_ref = $"../StatsManager"

func _ready() -> void:
	
	
	# Update the positioning of the tilemaps
	env_map.scale = Vector2(BOARD_SCALE, BOARD_SCALE)
	env_map.z_index = -1
	env_map.tile_set = environment.tileset

	highlight_map.scale = Vector2(BOARD_SCALE, BOARD_SCALE)
	highlight_map.tile_set = environment.tileset
	
	TILE_SIZE = env_map.tile_set.tile_size.x * BOARD_SCALE
	board_coord = [Vector2(0,0), TILE_SIZE * Vector2.ONE * (BOARD_SIZE)] 
	self.position.x = get_viewport().size.x/2 - board_coord[1].x/2
	initialise_matrix()
	

# Initialize 2d array matrix
func initialise_matrix() -> void:
	proc_gen.set_up()
	board_matrix = Array()
	board_matrix.resize(BOARD_SIZE)
	for i in range(BOARD_SIZE):
		board_matrix[i] = Array()
		board_matrix[i].resize(BOARD_SIZE)
		
	# Procedu
	proc_gen.generate_world(create_terrain_tile, place_building_on_tile, board_id)

# Terrain
func create_terrain_tile(tile_pos : Vector2i, terrain_id : String) -> void:
	var tileset_tile_coords = environment.getTilebyId(terrain_id)
	var darken_tile = 0
	
	# tile score display (can be extracted to a function)
	var score_label = new_tile_label()
	self.add_child(score_label)

	if (tile_pos.x + tile_pos.y) % 2 == 0:
		darken_tile = 1
	env_map.set_cell(tile_pos, 0, tileset_tile_coords, darken_tile)
	var board_tile = BoardTile.new(environment.getTileDatabyId(terrain_id), get_global_tile_pos(tile_pos))
	board_tile.score_display = score_label
	board_matrix[tile_pos.x][tile_pos.y] = board_tile

func new_tile_label() -> Label:
	var score_label = Label.new()
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.theme = preload("res://assets/fonts/cutey_card_theme.tres")
	score_label.set("theme_override_colors/font_color",Color(0,0.0,0.0,1.0))
	score_label.set("theme_override_font_sizes/font_size",30)
	score_label.z_index = 9
	score_label.visible = false
	return score_label
	
################################################################

func get_tile(coord : Vector2i) -> BoardTile:
	return board_matrix[coord.x][coord.y]

func get_global_tile_pos(coords : Vector2i) -> Vector2:
	if coords == NULL_TILE:
		return coords
	return to_global(tilecoords_to_localpos(coords))

func tilecoords_to_localpos(coords : Vector2i) -> Vector2:
	if coords == NULL_TILE:
		return coords
	var local_pos = Vector2((coords.x + 0.5) * TILE_SIZE, (coords.y + 0.5) * TILE_SIZE)
	return local_pos

func mouse_near_board() -> bool:
	var mouse_pos = get_local_mouse_position()
	const THRESHOLD = 150
	if mouse_pos.x > board_coord[0].x - THRESHOLD and mouse_pos.x < board_coord[1].x + THRESHOLD:
		return mouse_pos.y > board_coord[0].y - THRESHOLD and mouse_pos.y < board_coord[1].y + THRESHOLD
	return false
	
func get_mouse_tile_pos() -> Vector2i:
	var mouse_pos = get_local_mouse_position()
	var tile_mouse_pos = env_map.local_to_map(mouse_pos * 1.0/BOARD_SCALE)  
	if tile_mouse_pos.x >= 0 && tile_mouse_pos.x < BOARD_SIZE && tile_mouse_pos.y >= 0 && tile_mouse_pos.y < BOARD_SIZE:
		return tile_mouse_pos
	else:
		return NULL_TILE
		
func snap_mouse_to_tile_pos() -> Vector2:
	return get_global_tile_pos(get_mouse_tile_pos())

func get_global_length() -> int:
	return board_coord[1].x - board_coord[0].x 

# try to place building on tile or swap terrain
func place_building_on_tile(tile_pos : Vector2i, building: Building) -> bool:
	var score = get_total_score(building)
	var success = board_matrix[tile_pos.x][tile_pos.y].stack_if_able(building)
	if success:
		player_ref.add_score(score)
		add_child(building)
		building.position = tilecoords_to_localpos(tile_pos)
		building.get_node("JiggleAnimation").play("jiggle")
	return success
	#if placeable is Building:
		#
	#elif placeable is EnvTerrain:
		#tile_data.change_terrain(placeable)
		#env_map.set_cell(tile_pos, 0, environment.getTilebyId(placeable.tile_name), 0)
		#return true

# sums up score achieved based on current array of affected tiles
func get_total_score(building: Building) -> int:
	var sum : int = 0
	for highlight_tile_pos in affected_tiles:
		sum += get_tile(highlight_tile_pos).calculate_score(building)
	return sum

# Returns true if Placeable is successfully placed, else returns false
func place_on_board_if_able(building: Building) -> bool:
	var tile_mouse_pos : Vector2i = get_mouse_tile_pos()
	if tile_mouse_pos != NULL_TILE:
		return place_building_on_tile(tile_mouse_pos, building)
	return false

func constrain_pattern_to_board(pattern_arr : Array, tile_pos : Vector2i) -> Array[Vector2i] :
	var out_arr : Array[Vector2i] = []
	for relative_tile in pattern_arr:
		var true_tile = relative_tile + tile_pos
		if true_tile == true_tile.clampi(0, BOARD_SIZE - 1):
			out_arr.push_back(true_tile)
	return out_arr

# highlight affected tiles if building were to be placed
func preview_placement(try_building : Building, tile_pos : Vector2i) -> void :
	reset_preview()
	affected_tiles = constrain_pattern_to_board(try_building.AOE, tile_pos)
	for highlight_tile_pos in affected_tiles:
		highlight_map.set_cell(highlight_tile_pos,2, Vector2i(0,0),0)
		var highlight_tile: BoardTile = get_tile(highlight_tile_pos)
		highlight_tile.calculate_and_display(try_building)

func reset_preview() -> void :
	for tile_pos in affected_tiles:
		highlight_map.set_cell(tile_pos, -1, Vector2i(0,0), 0)
		get_tile(tile_pos).off_score_display()

#sets buildings in proper place and draw order
func redraw() -> void :
	pass
