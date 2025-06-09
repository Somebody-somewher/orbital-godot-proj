extends Node2D
class_name BoardManager

# Length/Width (no. cells) of board
## PLEASE KEEP THE BOARD a square
@export var BOARD_SIZE : Vector2i = Vector2i(8,8)
@export var BOARDS_LAYOUT : Vector2i = Vector2i(2,2)
@export var BORDER_DIM : Vector2i = Vector2i(4,4)
@export var BOARD_SCALE : float
var PLAYABLE_SPACE : Array[Vector2i]

@export var terrain_tilemap : BoardVisualManager
@export var previewer_tilemap : BoardPreviewerTileMap
@export var proc_gen : BoardProcGenerator

@export var object : Node
var matrix_data : BoardMatrixData

# reference for non-existent tile position
static var NULL_TILE = Vector2i(-1,-1)

# Global Coords of where board spans on screen
var boards_near_mouse : Array[bool]


var prev_tile_pos : Vector2i = Vector2i(-1,-1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var start_pos : Vector2i
	var end_pos : Vector2i
	var board_id : int = 0
			
	matrix_data = BoardMatrixData.new(BOARD_SIZE.x, BOARDS_LAYOUT)
	boards_near_mouse.resize(BOARDS_LAYOUT.x + BOARDS_LAYOUT.y)
	
	proc_gen.set_up(BOARD_SIZE, BOARDS_LAYOUT, BORDER_DIM)
	for i in range(4):
			proc_gen.generate_board(create_terrain, place_on_board_if_abled, i)
	
	proc_gen.generate_border(terrain_tilemap.change_border_terrain_tile, terrain_tilemap.place_fake_building)
	
	terrain_tilemap.set_up(BOARD_SIZE, BOARDS_LAYOUT, BORDER_DIM)
	
	previewer_tilemap.set_board_data(matrix_data)
	previewer_tilemap.set_up(object, BOARD_SIZE.x * BOARDS_LAYOUT.x, matrix_data.check_tilemap_tile_in_playable, BORDER_DIM)
	pass # Replace with function body.

func update_mouse_near_board() -> void:
	var mouse_pos = get_local_mouse_position()
	for b in len(matrix_data.boards_coords):
		if is_pos_near_board(mouse_pos, matrix_data.boards_coords[b]):
			boards_near_mouse[b] = true
		else:
			boards_near_mouse[b] = false

func is_pos_near_board(mouse_pos : Vector2i, board_start_end_pos : Array) -> bool:
	# Roughly one cell away
	var THRESHOLD = 1.5 * terrain_tilemap.TILE_SIZE
	
	var start_pos : Vector2i = to_global(terrain_tilemap.get_local_centre_of_tile(board_start_end_pos[0] + BORDER_DIM))
	var end_pos : Vector2i = to_global(terrain_tilemap.get_local_centre_of_tile(board_start_end_pos[1] + BORDER_DIM))
	
	if mouse_pos.x > start_pos.x - THRESHOLD and mouse_pos.x < end_pos.x + THRESHOLD:
			return mouse_pos.y > start_pos.y - THRESHOLD and mouse_pos.y < end_pos.y + THRESHOLD
	return false

func is_mouse_near_interactable_board() -> bool:
	for b in len(matrix_data.boards_coords):
		if boards_near_mouse[b] and matrix_data.interactable[b]:
			return true
	return false

func _process(delta: float) -> void:
	update_mouse_near_board()
	var curr_tile_pos : Vector2i = get_mouse_tile_pos() 
	if curr_tile_pos != prev_tile_pos and matrix_data.is_tilepos_in_interactable(curr_tile_pos - BORDER_DIM):
		Signalbus.emit_signal("mouse_enter_interactable_board_tile")
		prev_tile_pos = curr_tile_pos
	
	var start_pos : Vector2i 
	var end_pos : Vector2i
	for b in len(matrix_data.boards_coords):
		start_pos = matrix_data.boards_coords[b][0] + BORDER_DIM
		end_pos = matrix_data.boards_coords[b][1] + BORDER_DIM
		if boards_near_mouse[b] and matrix_data.interactable[b]:
			terrain_tilemap.unshade_area(start_pos, end_pos)
		else:
			terrain_tilemap.shade_area(start_pos, end_pos)
	pass

func get_mouse_tile_pos() -> Vector2i:
	var tile_mouse_pos = terrain_tilemap.get_mouse_tile_pos()
	if matrix_data.check_tilemap_tile_in_playable(tile_mouse_pos - BORDER_DIM):
		return tile_mouse_pos
	else:
		return NULL_TILE

# Returns true if Placeable is successfully placed, else returns false
# Client facing function
@rpc("authority", "call_local")
func place_on_board_if_abled(placeable: PlaceableData, tile_pos : Vector2i = NULL_TILE) -> bool:
	if tile_pos == NULL_TILE:
		tile_pos = get_mouse_tile_pos()
		
	if tile_pos != NULL_TILE and placeable.placeable(matrix_data, tile_pos - BORDER_DIM):
		#placeable.trigger_place_effects(matrix_data, tile_mouse_pos - BORDER_DIM)
		if placeable is BuildingData:
			terrain_tilemap.place_building_on_tile(placeable as BuildingData, tile_pos)
		
		matrix_data.add_placeable_to_tile(tile_pos - BORDER_DIM, Building.new_building_frm_data(placeable as BuildingData))

		return true
	return false

func place_on_board_if_able(placeable: PlaceableNode, tile_pos : Vector2i = NULL_TILE) -> bool:
	if tile_pos == NULL_TILE:
		tile_pos = get_mouse_tile_pos()
	
	if tile_pos != NULL_TILE and placeable.placeable(matrix_data, tile_pos - BORDER_DIM):
		#placeable.trigger_place_effects(matrix_data, tile_pos - BORDER_DIM)
		create_building(placeable, tile_pos)
		return true
	return false

func create_building(placeable: PlaceableNode, tile_pos : Vector2i) -> void:
	matrix_data.add_placeable_to_tile(tile_pos - BORDER_DIM, placeable)
	terrain_tilemap.place_building_on_tile(placeable.data, tile_pos)

func create_terrain(terrain : EnvTerrain, tile_pos : Vector2i) -> void:
	matrix_data.add_tile(tile_pos - BORDER_DIM, terrain)
	terrain_tilemap.change_terrain_tile(terrain, tile_pos)

func change_terrain(terrain : EnvTerrain, tile_pos : Vector2i = NULL_TILE) -> void:
	if tile_pos == NULL_TILE:
		tile_pos = get_mouse_tile_pos()
	
	if tile_pos != NULL_TILE:
		create_terrain(terrain, tile_pos)
