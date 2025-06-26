extends BoardManagerBase
class_name BoardManagerClient
# Main class that handles all "board" functionality. 
# Technically the "board" is made up of smaller "sub"-boards where each "sub"-board belongs to a player

# For the hover_over_tile signal
var prev_tile_pos : Vector2i = Vector2i(-1,-1)
var boards_near_mouse : Array[bool]

var player_board_ids : Array[int] 

# Called when the node enters the scene tree for the first time.
func set_up() -> void:	
	super.set_up()
	# Array of booleans to check which boards are being hovered over by mouse
	boards_near_mouse.resize(BOARDS_LAYOUT.x * BOARDS_LAYOUT.y)
		
	# Tilemaps setup
	previewer_tilemap.set_up(object, matrix_data, BORDER_DIM)
	terrain_tilemap.set_up(object, BORDER_DIM)
		
	var playable_area = matrix_data.get_playable_area_coords()
	terrain_tilemap.shade_area(playable_area[0], playable_area[1])

## Params supplied by server, called by all clients
@rpc("any_peer", "call_local")
func receive_init_data(board_size : Vector2i, board_layout : Vector2i, border_dim : Vector2i) -> void:
	BOARD_SIZE = board_size
	BOARDS_LAYOUT = board_layout
	BORDER_DIM = border_dim
	set_up()
	pass

func _ready() -> void:
	super._ready()
	NetworkManager.mark_client_ready(self.name)	

################################### PLACEABLE PLACING #########################################
func place_cardplaceable(placeableinst_id : String, tile_pos : Vector2i = NULL_TILE) -> void:
	if tile_pos == NULL_TILE:
		tile_pos = get_mouse_tile_pos()
	
	request_place_cardplaceable.rpc_id(1, placeableinst_id, tile_pos) 
	pass

@rpc("any_peer","call_local")
func client_place_cardplaceable(placeableinst_id : String, tile_pos : Vector2i) -> void:
	var placeable_instance : PlaceableInstanceData = CardLoader.local_search_hand(placeableinst_id)
	if placeable_instance != null:
		_place_placeable(placeable_instance, tile_pos)
		Signalbus.emit_signal("board_action_success")
	Signalbus.emit_signal("board_action_failure")

## Create a buildindg on a givne tilepos, data + visual
func _place_placeable(placeable_instance: PlaceableInstanceData, tile_pos : Vector2i) -> PlaceableNode:
	var placeable_node : PlaceableNode = super._place_placeable(placeable_instance, tile_pos)
	terrain_tilemap.place_building_on_tile(placeable_node, tile_pos)
	return placeable_node

################################# TERRAIN MODIFICATION ##########################################
@rpc("any_peer","call_local")
func create_terrain(terrain_id : String, tile_pos : Vector2i) -> void:
	if tile_pos == NULL_TILE:
		tile_pos = get_mouse_tile_pos()
		
	request_create_terrain.rpc_id(1, terrain_id, tile_pos)

@rpc("any_peer","call_local")
func _create_terrain(terrain_id : String, tile_pos : Vector2i) -> void:
	terrain_tilemap.change_terrain_tile(terrain_id, tile_pos)

@rpc("any_peer","call_local")
func change_terrain(terrain_id : String, tile_pos : Vector2i) -> void:
	if tile_pos == NULL_TILE:
		tile_pos = get_mouse_tile_pos()
	
	terrain_tilemap.change_terrain_tile(terrain_id, tile_pos)

@rpc("any_peer","call_local")
func _change_terrain(terrain_id : String, tile_pos : Vector2i) -> void:
	terrain_tilemap.change_terrain_tile(terrain_id, tile_pos)

########################################### UI #################################################
## Shade and unshade the individual boards that are interactable
@rpc("any_peer","call_local")
func set_interactable_board(boards: Array) -> void:
	var board_coords 
	for b in boards:
		board_coords = matrix_data.set_board_interactable(b)
		terrain_tilemap.unshade_area(board_coords[0] \
			, board_coords[1])

## Checks if any of the interactable boards are being hovered over 
func is_mouse_near_interactable_board() -> bool:
	for b in len(matrix_data.boards_coords):
		if boards_near_mouse[b] and matrix_data.interactable[b]:
			return true
	return false

## Get the tilepos of mouse
func get_mouse_tile_pos() -> Vector2i:
	var tile_mouse_pos = terrain_tilemap.get_mouse_tile_pos()
	if matrix_data.check_tilepos_in_playable(terrain_tilemap.tilemap_to_matrix(tile_mouse_pos)):
		return tile_mouse_pos
	else:
		return NULL_TILE

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

func _process(delta: float) -> void:
	if !NetworkManager.is_sync_fin:
		return
		
	# Update the array which represents on all boards (on whether they are being hovered over)
	update_mouse_near_board()
	# Checks whether the mouse is hovering over a new interactable tile, sends a signal out if so
	# Impt for card_manager to show indicator that the card can be placed on the board
	var curr_tile_pos : Vector2i = get_mouse_tile_pos() 
	if curr_tile_pos != prev_tile_pos: #and matrix_data.get_boardcoords_of_tilepos(terrain_tilemap.tilemap_to_matrix(curr_tile_pos)) != []:
		Signalbus.emit_signal("mouse_enter_interactable_board_tile")
		prev_tile_pos = curr_tile_pos
	
	pass

################################################################################################
@rpc("any_peer", "call_local")
func remove_building(tile_pos : Vector2i = NULL_TILE) -> void:
	pass

func tilemap_to_matrix(tilemap_pos : Vector2i) -> Vector2i:
	return tilemap_pos - BORDER_DIM 

func matrix_to_tilepos(matrix_pos : Vector2i) -> Vector2i:
	return BORDER_DIM + matrix_pos
