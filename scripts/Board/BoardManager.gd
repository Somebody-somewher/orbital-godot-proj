extends Node2D
class_name BoardManager

# Length/Width (no. cells) of board
@export var BOARD_SIZE : Vector2i = Vector2i(8,8)
@export var BOARDS_LAYOUT : Vector2i = Vector2i(2,2)
@export var BORDER_DIM : Vector2i = Vector2i(4,4)
@export var BOARD_SCALE : Vector2i
var PLAYABLE_SPACE : Array[Vector2i]

@export var terrain_tilemap : BoardVisualManager

# reference for non-existent tile position
static var NULL_TILE = Vector2i(-1,-1)

# Global Coords of where board spans on screen
var boards : Array[BoardMatrixData]
var boards_near_mouse : Array[bool]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var start_pos : Vector2i
	var end_pos : Vector2i
	var board_id : int = 0
	
	terrain_tilemap.set_up(BOARD_SIZE, BOARDS_LAYOUT, BORDER_DIM)
	
	var curr_board : BoardMatrixData
	for y in range(BOARDS_LAYOUT.y):
		for x in range(BOARDS_LAYOUT.x):
			start_pos = Vector2i(BORDER_DIM.x + x  * BOARD_SIZE.x,BORDER_DIM.y + y * BOARD_SIZE.y)
			end_pos = start_pos + BOARD_SIZE - Vector2i(1,1)
			
			curr_board = BoardMatrixData.new(board_id,BOARD_SIZE.x,[start_pos, end_pos])
			
			#TODO: only for testing, change later
			if x + y % 2 == 1:
				curr_board.interactable = false
			
			boards.append(curr_board)
			boards_near_mouse.append(false)
			board_id += 1
	
	PLAYABLE_SPACE = [boards[0].start_end_pos[0], boards[len(boards)].start_end_pos[1]]
	
	pass # Replace with function body.

func update_mouse_near_board() -> void:
	var mouse_pos = get_local_mouse_position()
	var start_pos : Vector2i
	var end_pos : Vector2i
	for b in len(boards):
		if is_pos_near_board(mouse_pos, boards[b]):
			boards_near_mouse[b] = true
		else:
			boards_near_mouse[b] = false

func is_pos_near_board(mouse_pos : Vector2i, board : BoardMatrixData) -> bool:
	# Roughly one cell away
	var THRESHOLD = 1.5 * terrain_tilemap.TILE_SIZE
	
	var start_pos : Vector2i = to_global(terrain_tilemap.get_local_centre_of_tile(board.start_end_pos[0]))
	var end_pos : Vector2i = to_global(terrain_tilemap.get_local_centre_of_tile(board.start_end_pos[1]))
	
	if mouse_pos.x > start_pos.x - THRESHOLD and mouse_pos.x < end_pos.x + THRESHOLD:
			return mouse_pos.y > start_pos.y - THRESHOLD and mouse_pos.y < end_pos.y + THRESHOLD
	return false

func is_mouse_near_board() -> bool:
	for b in len(boards):
		if boards_near_mouse[b]:
			return true
	return false

func _process(delta: float) -> void:
	update_mouse_near_board()
	for b in len(boards):
		if boards_near_mouse[b]:
			terrain_tilemap.unshade_area(boards[b].start_end_pos[0],boards[b].start_end_pos[1])
		else:
			terrain_tilemap.shade_area(boards[b].start_end_pos[0],boards[b].start_end_pos[1])
	pass

func get_mouse_tile_pos() -> Vector2i:
	var mouse_pos = get_local_mouse_position()
	var tile_mouse_pos = terrain_tilemap.local_to_map(mouse_pos * 1.0/BOARD_SCALE)  
	if tile_mouse_pos.x >= 0 && tile_mouse_pos.x < BOARD_SIZE && tile_mouse_pos.y >= 0 && tile_mouse_pos.y < BOARD_SIZE:
		return tile_mouse_pos
	else:
		return NULL_TILE

# Returns true if Placeable is successfully placed, else returns false
# Client facing function
func place_on_board_if_able(placeable: PlaceableData) -> bool:
	var tile_mouse_pos : Vector2i = get_local_mouse_position()
	
	if tile_mouse_pos != NULL_TILE and placeable.placeable(self, tile_mouse_pos):
		# MUST ADD CHILD BEFORE TRIGGER PLACE EVENT (add child initlizes the build which connects signals for scoring)
		placeable.trigger_place_effects(self, tile_mouse_pos)
		place_building_on_tile(placeable, tile_mouse_pos)
		
		return true
	return false
