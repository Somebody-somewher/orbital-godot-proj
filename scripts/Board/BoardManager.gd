extends Node2D
class_name BoardManager
# Main class that handles all "board" functionality. 
# Technically the "board" is made up of smaller "sub"-boards where each "sub"-board belongs to a player

####################### KEY DEFINING BOARD VARS ##########################
######### ALL TO BE STANDARDIZED BY SERVER BOARDMANAGER INSTANCE #########
# Length/Width (no. cells) of board
## PLEASE KEEP THE BOARD SQUARE FOR NOW
@export var BOARD_SIZE : Vector2i = Vector2i(8,8)

@export var BOARDS_LAYOUT : Vector2i = Vector2i(2,2)
@export var BORDER_DIM : Vector2i = Vector2i(4,4)
@export var BOARD_SCALE : float
#########################################################################

@export var terrain_tilemap : BoardVisualManager
@export var previewer_tilemap : BoardPreviewerTileMap
@export var object : Node
# The "true" matrix data is stored on server
# Every client has its own client-side matrix for preview of ghost placeable image
var matrix_data : BoardMatrixData

# reference for non-existent tile position
static var NULL_TILE = Vector2i(-1,-1)

# For the hover_over_tile signal
var prev_tile_pos : Vector2i = Vector2i(-1,-1)
var boards_near_mouse : Array[bool]

var player_board_ids : Array[int] 
######### These components only exist server side ########### 
@export var proc_gen : BoardProcGenerator
var board_layout : BoardLayout
##############################################################

# Called when the node enters the scene tree for the first time.
func set_up() -> void:	
	# Actual Board Data, contains all playable boards 
	matrix_data = BoardMatrixData.new(BOARD_SIZE.x, BOARDS_LAYOUT)
	
	# Array of booleans to check which boards are being hovered over by mouse
	boards_near_mouse.resize(BOARDS_LAYOUT.x * BOARDS_LAYOUT.y)
	
	# Tilemaps setup
	previewer_tilemap.set_up(object, matrix_data, BORDER_DIM)
	terrain_tilemap.set_up(object, BORDER_DIM)

@rpc("authority", "call_local")
func client_procgen_init(create_terrain : Callable, create_border_tile : Callable, create_building : Callable, create_fake_building : Callable) -> void:
	if proc_gen != null:
		# Procedural Generation setup
		for i in range(BOARDS_LAYOUT.x * BOARDS_LAYOUT.y):
				proc_gen.generate_board(create_terrain, create_building, i)
		proc_gen.generate_border(create_border_tile, create_fake_building)
	else:
		var placeholder_env = terrain_tilemap.env_map.getPlaceholderTile()
		for x in range(BOARD_SIZE.x * BOARDS_LAYOUT.x):
			for y in range(BOARD_SIZE.y * BOARDS_LAYOUT.y):
				create_terrain.call(placeholder_env, Vector2i(x,y))

@rpc("any_peer", "call_local")
func server_supply_init_data(board_size : Vector2i, board_layout : Vector2i, border_dim : Vector2i) -> void:
	BOARD_SIZE = board_size
	BOARDS_LAYOUT = board_layout
	BORDER_DIM = border_dim
	set_up()
	print("Setting up BoardManager for ", multiplayer.get_unique_id())
	if NetworkManager.is_client():
		client_procgen_init.rpc_id(1, create_terrain, terrain_tilemap.change_border_terrain_tile, place_on_board_if_able_data, terrain_tilemap.place_fake_building)
	pass

func _ready() -> void:
	print("BOARDMANAGER READY FOR ", multiplayer.get_unique_id())
	if multiplayer.is_server(): #and BOARDS_LAYOUT = Vector2i(-1, -1):
		print("SERVER ACTIVATE")
		NetworkManager.connect("all_clients_ready", init_clients)
		BOARDS_LAYOUT = BoardLayout.new().get_board_layout(PlayerManager.getNumPlayers())
		if proc_gen != null:
			proc_gen.set_up(BOARD_SIZE, BOARDS_LAYOUT, BORDER_DIM)
	NetworkManager.mark_client_ready(self)	

func init_clients() -> void:
	print("init clients!")
	server_supply_init_data.rpc(BOARD_SIZE, BOARDS_LAYOUT, BORDER_DIM)

## Called in _process to check each board is being hovered over, update the array if so
## In case it matters "which" board is being hovered over
func update_mouse_near_board() -> void:
	var mouse_pos = get_local_mouse_position()
	for b in len(matrix_data.boards_coords):
		if is_pos_near_board(mouse_pos, matrix_data.boards_coords[b]):
			boards_near_mouse[b] = true
		else:
			boards_near_mouse[b] = false

## Actual chec whether the mouse is near board
func is_pos_near_board(mouse_pos : Vector2i, board_start_end_pos : Array) -> bool:
	# Roughly one cell away
	var THRESHOLD = 1.5 * terrain_tilemap.TILE_SIZE
	var start_pos : Vector2i = terrain_tilemap.get_local_centre_of_tile(terrain_tilemap.matrix_to_tilepos(board_start_end_pos[0]))
	var end_pos : Vector2i = terrain_tilemap.get_local_centre_of_tile(terrain_tilemap.matrix_to_tilepos(board_start_end_pos[1]))
	if mouse_pos.x > start_pos.x - THRESHOLD and mouse_pos.x < end_pos.x + THRESHOLD:
			return mouse_pos.y > start_pos.y - THRESHOLD and mouse_pos.y < end_pos.y + THRESHOLD
	return false

## Checks if any of the interactable boards are being hovered over 
func is_mouse_near_interactable_board() -> bool:
	for b in len(matrix_data.boards_coords):
		if boards_near_mouse[b] and matrix_data.interactable[b]:
			return true
	return false

func _process(delta: float) -> void:
	# Update the array which represents on all boards (on whether they are being hovered over)
	update_mouse_near_board()
	# Checks whether the mouse is hovering over a new interactable tile, sends a signal out if so
	# Impt for card_manager to show indicator that the card can be placed on the board
	var curr_tile_pos : Vector2i = get_mouse_tile_pos() 
	if curr_tile_pos != prev_tile_pos: #and matrix_data.get_boardcoords_of_tilepos(terrain_tilemap.tilemap_to_matrix(curr_tile_pos)) != []:
		Signalbus.emit_signal("mouse_enter_interactable_board_tile")
		prev_tile_pos = curr_tile_pos
	highlight_interactable_board()
	
	pass

## Get the tilepos of mouse
func get_mouse_tile_pos() -> Vector2i:
	var tile_mouse_pos = terrain_tilemap.get_mouse_tile_pos()
	if matrix_data.check_tilepos_in_playable(terrain_tilemap.tilemap_to_matrix(tile_mouse_pos)):
		return tile_mouse_pos
	else:
		return NULL_TILE

## Returns true if Placeable is successfully placed, else returns false
# Client facing function
@rpc("any_peer", "call_local")
func place_on_board_if_able_data(placeable: PlaceableData, tile_pos : Vector2i = NULL_TILE) -> bool:
	if tile_pos == NULL_TILE:
		tile_pos = get_mouse_tile_pos()
		
	if tile_pos != NULL_TILE and placeable.placeable(matrix_data, terrain_tilemap.tilemap_to_matrix(tile_pos)):
		#placeable.trigger_place_effects(matrix_data, tile_mouse_pos - BORDER_DIM)
		if placeable is BuildingData:
			var building = Building.new_building_frm_data(placeable as BuildingData)
			create_building(building, tile_pos)
			#terrain_tilemap.place_building_on_tile(building, tile_pos)
			#matrix_data.add_placeable_to_tile(terrain_tilemap.tilemap_to_matrix(tile_pos), building)
		return true
	return false

## Returns true if Placeable is successfully placed, else returns false
# Client facing function
@rpc("any_peer", "call_local")
func place_on_board_if_able(placeable: PlaceableNode, tile_pos : Vector2i = NULL_TILE) -> bool:
	if tile_pos == NULL_TILE:
		tile_pos = get_mouse_tile_pos()
	
	if tile_pos != NULL_TILE and placeable.placeable(matrix_data, terrain_tilemap.tilemap_to_matrix(tile_pos)):
		#placeable.trigger_place_effects(matrix_data, terrain_tilemap.tilemap_to_matrix(tile_pos))
		create_building(placeable, tile_pos)
		return true
	return false

## Create a buildindg on a givne tilepos, data + visual
func create_building(placeable: PlaceableNode, tile_pos : Vector2i) -> void:
	matrix_data.add_placeable_to_tile(terrain_tilemap.tilemap_to_matrix(tile_pos), placeable)
	terrain_tilemap.place_building_on_tile(placeable, tile_pos)

## Initial creation of terrain tiles for procgen
func create_terrain(terrain : EnvTerrain, tile_pos : Vector2i) -> void:
	matrix_data.add_tile(terrain_tilemap.tilemap_to_matrix(tile_pos), terrain)
	terrain_tilemap.change_terrain_tile(terrain, tile_pos)

## Change terrain, data + visual
func change_terrain(terrain : EnvTerrain, tile_pos : Vector2i = NULL_TILE) -> void:
	if tile_pos == NULL_TILE:
		tile_pos = get_mouse_tile_pos()
	
	if tile_pos != NULL_TILE:
		create_terrain(terrain, tile_pos)

## Shade and unshade the individual boards that are interactable
func highlight_interactable_board() -> void:
	var start_pos : Vector2i 
	var end_pos : Vector2i
	for b in len(matrix_data.boards_coords):
		start_pos = terrain_tilemap.matrix_to_tilepos(matrix_data.boards_coords[b][0])
		end_pos = terrain_tilemap.matrix_to_tilepos(matrix_data.boards_coords[b][1])
		if boards_near_mouse[b] and matrix_data.interactable[b]:
			terrain_tilemap.unshade_area(start_pos, end_pos)
		else:
			terrain_tilemap.shade_area(start_pos, end_pos)

func remove_building(tile_pos : Vector2i = NULL_TILE) -> void:
	if tile_pos == NULL_TILE:
		tile_pos = get_mouse_tile_pos()
