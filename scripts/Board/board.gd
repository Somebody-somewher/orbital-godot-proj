extends Node2D
class_name Board

@onready
var highlight_map : TileMapLayer = $"./Highlights"
# TerrainDisplay vs TerrainActual https://www.youtube.com/watch?v=jEWFSv3ivTg

@onready 
var env_tilemap : TileMapLayer = $"./TerrainActual"

# Every board is uniquely associated with a player
var board_id = 0

# reference for non-existent tile position
static var NULL_TILE = Vector2i(-1,-1)

# Length/Width (no. cells) of board
@export var BOARD_SIZE : int = 6
@export var BOARD_SCALE : float = 0.1
var TILE_SIZE : float

# Global Coords of where board spans on screen
var board_coord : Array[Vector2] #pair of coords, top left corner and bottom right corner

@export var proc_gen : ProceduralGenerator = preload("res://Resources/ProcGen/DummyProcGen.tres")
 
# Contains the terrain_id -> terrain tileset mapping
@export var environment : EnvTerrainMapping = preload("res://Resources/EnvTerrain/TestEnvTerrainMapping.tres")


#################### FOR INIT ##################################
# makes hovering on and off reset relevant tiles only and not the whole board
var board_preview : BoardPreviewer

# Contains a 2d Matrix of BoardTiles
var board_matrix : BoardMatrixData

func _ready() -> void:
	# Update the positioning of the tilemaps
	env_tilemap.scale = Vector2(BOARD_SCALE, BOARD_SCALE)
	env_tilemap.z_index = -1
	env_tilemap.tile_set = environment.tileset

	highlight_map.scale = Vector2(BOARD_SCALE, BOARD_SCALE)
	highlight_map.tile_set = environment.tileset
	
	TILE_SIZE = env_tilemap.tile_set.tile_size.x * BOARD_SCALE
	board_coord = [Vector2(0,0), TILE_SIZE * Vector2.ONE * (BOARD_SIZE)] 
	
	self.position.x = get_viewport().size.x/2 - board_coord[1].x/2
	
	board_preview = BoardPreviewer.new(self, highlight_map, get_global_tile_pos, BOARD_SIZE)
	board_matrix = BoardMatrixData.new(BOARD_SIZE)
	
	# Get Procedural Generation Matrix
	if proc_gen == null:
		for x in range(BOARD_SIZE):
			for y in range(BOARD_SIZE):
				create_terrain_tile(Vector2i(x,y), "Grass")
	else:
		proc_gen.generate_world(create_terrain_tile, place_building_on_tile, board_id)
	
########################## POSITIONING HELPER FUNCTIONS #############################################

func get_global_tile_pos(coords : Vector2i) -> Vector2:
	if coords == NULL_TILE:
		return coords
	return to_global(get_local_centre_of_tile(coords))

func get_local_centre_of_tile(coords : Vector2i) -> Vector2:
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
	var tile_mouse_pos = env_tilemap.local_to_map(mouse_pos * 1.0/BOARD_SCALE)  
	if tile_mouse_pos.x >= 0 && tile_mouse_pos.x < BOARD_SIZE && tile_mouse_pos.y >= 0 && tile_mouse_pos.y < BOARD_SIZE:
		return tile_mouse_pos
	else:
		return NULL_TILE
		
func snap_mouse_to_tile_pos() -> Vector2:
	return get_global_tile_pos(get_mouse_tile_pos())

func get_global_length() -> int:
	return board_coord[1].x - board_coord[0].x 

############################### PLACEMENT FUNCTIONS ##################################################
# Terrain
func create_terrain_tile(tile_pos : Vector2i, terrain_id : String) -> void:
	var tileset_tile_coords = environment.getTilebyId(terrain_id)
	var darken_tile = 0
	
	# Every alternate tile, set the alternate colour in the tilemap
	if (tile_pos.x + tile_pos.y) % 2 == 1:
		darken_tile = 1	
	env_tilemap.set_cell(tile_pos, 0, tileset_tile_coords, darken_tile)
	
	board_matrix.add_tile(tile_pos, environment.getTileDatabyId(terrain_id))

# try to place placeable on tile
# Private function
func place_building_on_tile(tile_pos : Vector2i, placeable: PlaceableNode) -> void:
	placeable.z_index = tile_pos.y
	add_child(placeable)
	
	# MUST ADD CHILD BEFORE TRIGGER PLACE EVENT (add child initlizes the build which connects signals for scoring)
	placeable.trigger_place_effects(self, tile_pos)
	# MUST TRIGGER BEFORE ADDING (otherwise places self on board then can score against itself)
	board_matrix.add_placeable_to_tile(tile_pos, placeable)
	
	placeable.position = get_local_centre_of_tile(tile_pos)
	placeable.get_node("JiggleAnimation").play("jiggle")

# Returns true if Placeable is successfully placed, else returns false
# Client facing function
func place_on_board_if_able(placeable: PlaceableNode) -> bool:
	var tile_mouse_pos : Vector2i = get_mouse_tile_pos()
	if tile_mouse_pos != NULL_TILE and placeable.placeable(self, tile_mouse_pos):
		place_building_on_tile(tile_mouse_pos, placeable)
		return true
	return false

# highlight scoring tiles if building were to be placed
# CARDMANAGER highlight_effects_when_hovering_card -> preview placement -> BoardPreviewer preview 
# -> calls placeable data's preview event which is a board event
func preview_placement(try_placeable : PlaceableNode, tile_pos : Vector2i) -> void:
	board_preview.set_preview(self, try_placeable, tile_pos)

func reset_preview() -> void :
	board_preview.reset_preview()

#sets buildings in proper place and draw order
func redraw() -> void :
	pass
