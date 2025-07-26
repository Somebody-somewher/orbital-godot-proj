extends BoardManagerBase
class_name BoardManagerClient
# Main class that handles all "board" functionality. 
# Technically the "board" is made up of smaller "sub"-boards where each "sub"-board belongs to a player

@export var terrain_tilemap : BoardVisualManager
@export var terrain_underlayer : BoardTileMapLayer
@export var previewer_tilemap : BoardPreviewerTileMap
@export var object : Node

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
	var playable_area = matrix_data.get_playable_area_coords()
	terrain_tilemap.set_up(object, BORDER_DIM, playable_area)	
	terrain_underlayer.set_up(object, BORDER_DIM, playable_area)	
	previewer_tilemap.set_up(object, BORDER_DIM, playable_area, client_interactability_check)
	
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

######################################## PROCGEN ##############################################
@rpc("any_peer","call_local")
func _client_create_border_fake_tile(tid : String, tile_pos : Vector2i) -> void:
	terrain_tilemap.change_border_terrain_tile(tid, tile_pos)
	terrain_underlayer.change_border_terrain_tile(tile_pos)

@rpc("any_peer","call_local")
func _client_create_border_fake_building(bid : String, tile_pos : Vector2i) -> void:
	terrain_tilemap.place_fake_building(bid, tile_pos)
################################### PLACEABLE PLACING #########################################

## Client drags card to board, function calls server to request validation
func place_cardplaceable(placeableinst_id : String, tile_pos : Vector2i = NULL_TILE, run_on_place_events := true, sync := true) -> void:
	if tile_pos == NULL_TILE:
		tile_pos = get_mouse_tile_pos()
	
	request_place_cardplaceable.rpc_id(1, placeableinst_id, tile_pos, run_on_place_events, sync) 
	

## Server calls this client function for actual placement clientside
## This is called on other clients to sync buildings together
@rpc("any_peer","call_local")
func _client_sync_placeable(placeable_serialized : Dictionary, tile_pos : Vector2i, requester_uuid : String) -> void:
	print_debug("Multiplayer placed thing: ", multiplayer.get_unique_id(), placeable_serialized['instance_id'], tile_pos, requester_uuid)
	# The server already placed the placeable since it had to validate the code
	var requester_check := PlayerManager.amIPlayer(requester_uuid)
	if multiplayer.is_server():
		if requester_check:
			Signalbus.emit_signal("board_action_result", true)
		return
		
	var placeable_instance : PlaceableInstanceData = CardLoader.sync_create_data_instance(placeable_serialized)		
	if placeable_instance:
		_place_placeable(placeable_instance, tile_pos, false)
		if requester_check:
			Signalbus.emit_signal("board_action_result", true)
	else:
		printerr("Error generaating new data instance")
		if requester_check:
			Signalbus.emit_signal("board_action_result", false)

## Create a buildindg on a given tilepos, data (from server) + visual (mostly this code in client)
func _place_placeable(placeable_instance: PlaceableInstanceData, tile_pos : Vector2i, run_on_place_effects := true) -> void:
	var placeable_node : PlaceableNode
	
	if placeable_instance is BuildingInstanceData:
		placeable_node = Building.new_building_frm_data(placeable_instance as BuildingInstanceData)
		terrain_tilemap.place_building_on_tile(placeable_node, tile_pos)
		
	placeable_instance.client_on_place(placeable_node.destroy)
	
	super._place_placeable(placeable_instance, tile_pos, run_on_place_effects)
	
	if run_on_place_effects:
		var terrain : String 
		match(matrix_data.get_tile(tilemap_to_matrix(tile_pos))._terrain.get_id()):
			"Grass" :
				terrain = "grass"
			"Desert" :
				terrain = "sand"
			"Water":
				terrain = "water"
		Signalbus.show_fx.emit(terrain, terrain_tilemap.get_local_centre_of_tile(tile_pos))
		AudioManager.play_sfx(terrain)

@rpc("any_peer", "call_local")
func remove_building(tile_pos : Vector2i = NULL_TILE) -> void:
	pass

################################# TERRAIN MODIFICATION ##########################################
#@rpc("any_peer","call_local")
#func create_terrain(terrain_id : String, tile_pos : Vector2i) -> void:
	#if tile_pos == NULL_TILE:
		#tile_pos = get_mouse_tile_pos()
		#
	#request_create_terrain.rpc_id(1, terrain_id, tile_pos)

@rpc("any_peer","call_local")
func _create_terrain(terrain_id : String, tile_pos : Vector2i) -> void:
	super._create_terrain(terrain_id, tile_pos)
	terrain_tilemap.change_terrain_tile(terrain_id, tile_pos)
	terrain_underlayer.change_terrain_tile(tile_pos)

#@rpc("any_peer","call_local")
#func change_terrain(terrain_id : String, tile_pos : Vector2i) -> void:
	#if tile_pos == NULL_TILE:
		#tile_pos = get_mouse_tile_pos()
	#
	#terrain_tilemap.change_terrain_tile(terrain_id, tile_pos)

@rpc("any_peer","call_local")
func _change_terrain(terrain_id : String, tile_pos : Vector2i) -> void:
	super._change_terrain(terrain_id, tile_pos)
	terrain_tilemap.change_terrain_tile(terrain_id, tile_pos)

########################################### UI #################################################
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
	if !NetworkManager.is_sync_fin or SceneManager.is_gameplay_paused:
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

#################################### BOARD INTERACTABILITY #################################################
@rpc("any_peer","call_local")
func client_set_interactable_board(boards: Array) -> void:
	var board_coords 
	for b in boards:
		board_coords = matrix_data.set_board_interactable(b)
		terrain_tilemap.unshade_area(board_coords[0] \
			, board_coords[1])

func client_interactability_check(tile_pos : Vector2i, upon_success : Callable) -> bool:
	if tile_pos != NULL_TILE and !SceneManager.is_gameplay_paused and\
		!matrix_data.get_interactable_boardcoords_of_tilepos(tilemap_to_matrix(tile_pos)).is_empty():
		return upon_success.call()
	else:
		return false
############################################ MISC ############################################################

func get_board_coords() -> Array[Vector2]:
	return terrain_tilemap.viewable_area_coords

@rpc("any_peer", "call_local")
func _on_board_failed_action_by_server() -> void:
	Signalbus.emit_signal("board_action_result", false)
	
