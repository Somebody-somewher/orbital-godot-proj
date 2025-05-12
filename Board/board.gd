extends Node2D

signal mouse_over_tile
signal mouse_off_tile

# TerrainDisplay vs TerrainActual https://www.youtube.com/watch?v=jEWFSv3ivTg
@onready
var env_map : TileMapLayer = $"./TerrainActual"

# Contains a 2d Matrix of tile instances
var board_matrix

# Length/Width (no. cells) of board
@export var BOARD_SIZE = 5
@export var BOARD_SCALE : float = 0.13 

# Position of where the board is created on screen
@export var offset = Vector2(200,100) #pixel width of one tile
var board_coord : Array[Vector2] #top left tile and bottom right tile

@export var proc_gen : ProceduralGenerator = preload("res://ProceduralGeneration/DummyProcGen.tres")

@export var environment : EnvTerrainMapping = preload("res://Env & Buildings/EnvTerrain/TestEnvTerrainMapping.tres")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Update the positioning of the tilemaps
	env_map.scale = Vector2(BOARD_SCALE, BOARD_SCALE)
	env_map.position = to_local(offset)
	env_map.tile_set = environment.tileset
	
	#TODO: Check if this works correctly
	board_coord = [offset, offset + env_map.tile_set.tile_size * (BOARD_SIZE-1) * BOARD_SCALE] 

	proc_gen.generate_world()
	initialise_matrix()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_local_mouse_position ()
	var tile_mouse_pos = env_map.local_to_map((mouse_pos - offset) * 1.0/BOARD_SCALE)  
	
	if tile_mouse_pos.x >= 0 && tile_mouse_pos.x < BOARD_SIZE && tile_mouse_pos.y >= 0 && tile_mouse_pos.y < BOARD_SIZE:
		emit_signal("mouse_over_tile", func(placeable: Placeable):  place_on_tile(tile_mouse_pos, placeable))
	else:
		emit_signal("mouse_off_tile")


# Initialize 2d array matrix
func initialise_matrix() -> void:
	board_matrix = Array()
	board_matrix.resize(BOARD_SIZE)
	for i in range(BOARD_SIZE):
		board_matrix[i] = Array()
		board_matrix[i].resize(BOARD_SIZE)
		for j in range(BOARD_SIZE): 
			board_matrix[i][j] = spawn_tile(i, j)

func spawn_tile(i, j):	
	# To achieve the alternative darkened tiles: 
	# Shaders
	# https://www.youtube.com/watch?v=eYlBociPwdw
	# Or alternative tiles in the tilemap with modulation?
	var id : String = proc_gen.getTerrainAtCell(i,j) 
	env_map.set_cell(Vector2(i,j), 0, environment.getTilebyId(id), 0)
	return BoardTile.new(environment.getTileDatabyId(id))

func mouse_near_board(mouse_pos):
	const THRESHOLD = 150
	if mouse_pos.x > board_coord[0].x - THRESHOLD and mouse_pos.x < board_coord[1].x + THRESHOLD:
		return mouse_pos.y > board_coord[0].y - THRESHOLD and mouse_pos.y < board_coord[1].y + THRESHOLD

# TODO: Not sure how you want to handle the card class
func place_on_tile(tile_pos : Vector2i, placeable: Placeable):
	var tile_data = board_matrix[tile_pos.x][tile_pos.y]
	if placeable is Building:
		tile_data.add_building(placeable)
		#TODO: get Buildings terrainmap up and running
	elif placeable is EnvTerrain:
		tile_data.change_terrain = placeable
		env_map.set_cell(tile_pos, 0, environment.getTilebyId(placeable.tile_name), 0)
		
	
	
