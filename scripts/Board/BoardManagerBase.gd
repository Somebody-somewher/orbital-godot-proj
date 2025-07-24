extends Node2D
class_name BoardManagerBase
# Main class that handles all "board" functionality. 
# Technically the "board" is made up of smaller "sub"-boards where each "sub"-board belongs to a player

####################### KEY DEFINING BOARD VARS ##########################
######### ALL TO BE STANDARDIZED BY SERVER BOARDMANAGER INSTANCE #########
# Length/Width (no. cells) of board
## PLEASE KEEP THE BOARD SQUARE FOR NOW
@export var BOARD_SIZE : Vector2i = Vector2i(8,8)
@export var BOARDS_LAYOUT : Vector2i = Vector2i(2,2)
@export var BORDER_DIM : Vector2i = Vector2i(4,4)
#########################################################################

@export var env_map : EnvTerrainMapping 

#@export var terrain_tilemap : BoardVisualManager
# The "true" matrix data is stored on server
# Every client has its own client-side matrix for preview of ghost placeable image
var matrix_data : BoardMatrixData

# reference for non-existent tile position
static var NULL_TILE = Vector2i(-1,-1)

######### These components only exist server side ########### 
@export var proc_gen : BoardProcGenerator
var board_layout_gen : BoardLayout
##############################################################

# Called when the node enters the scene tree for the first time.
func set_up() -> void:	
	# Actual Board Data, contains all playable boards 
	matrix_data = BoardMatrixData.new(BOARD_SIZE.x, BOARDS_LAYOUT)
	
	CardLoader.event_manager.matrix_data = matrix_data
	Signalbus.place_placeable.connect(server_place_newplaceable)
	Signalbus.remove_placeable.connect(server_remove_building)

## This is run by the server to supply data to all clients
## Signal-activated by NetworkManager "all_clients_ready"
func init_clients() -> void:
	receive_init_data.rpc(BOARD_SIZE, BOARDS_LAYOUT, BORDER_DIM)
	procgen_init(func(tid : String, tile_pos : Vector2i): _create_terrain.rpc(tid, tile_pos) \
	, func(tid : String, tile_pos : Vector2i): _client_create_border_fake_tile.rpc(tid, tile_pos) \
	, create_terrain_building \
	, func(bid : String, tile_pos : Vector2i): _client_create_border_fake_building.rpc(bid, tile_pos))
	board_layout_gen.set_ui_interactable()
	
	# This is to mark the client as synced up
	NetworkManager.mark_client_ready.rpc(self.name)

func procgen_init(create_terrain : Callable, create_border_tile : Callable,\
		 create_building : Callable, create_fake_building : Callable) -> void:
	if proc_gen != null:
		# Procedural Generation setup
		for i in range(BOARDS_LAYOUT.x * BOARDS_LAYOUT.y):
				proc_gen.generate_board(create_terrain, i)
		proc_gen.generate_actual_buildings(create_building)
		proc_gen.generate_border(create_border_tile, create_fake_building)
	else:
		
		var placeholder_id = env_map.getPlaceholderTile().get_id()
		for x in range(BOARD_SIZE.x * BOARDS_LAYOUT.x):
			for y in range(BOARD_SIZE.y * BOARDS_LAYOUT.y):
				create_terrain.call(placeholder_id, Vector2i(x,y))

func _ready() -> void:
	# Server setup code
	if multiplayer.is_server():
		# Signal telling server that all clients are ready to receive info
		NetworkManager.connect("all_clients_ready", init_clients)
		board_layout_gen = BoardLayout.new(func(player_id : int, boards : Array): \
			client_set_interactable_board.rpc_id(player_id, boards))
		
		BOARDS_LAYOUT = board_layout_gen.get_board_layout(PlayerManager.getNumPlayers())
		if proc_gen != null:
			proc_gen.set_up(BOARD_SIZE, BOARDS_LAYOUT, BORDER_DIM)

############################### INITIAL PROCGEN FUNCTIONS ####################################
@rpc("any_peer", "call_local")
func create_terrain_building(builddata_tilepos_dict : Dictionary[BuildingData, Array]) -> void:
	var data_arr : Array[String]
	var board_positions : Array[Vector2i]
	var attr_arr : Array[Array]
	
	for building in builddata_tilepos_dict.keys():
		for tilepos in builddata_tilepos_dict[building]:
			data_arr.append(building.get_id())
			board_positions.append(tilepos)
	
	attr_arr.assign(CardLoader.card_attribute_gen.generate_card_stream(data_arr))
	_create_terrain_building.rpc(data_arr, board_positions, attr_arr)

@rpc("any_peer", "call_local")
func _create_terrain_building(building_id: Array[String], tilepos: Array[Vector2i], card_attr : Array) -> void:
	var building_instance : BuildingInstanceData
	var building : Building
	for index in range(len(card_attr)):
		building_instance = CardLoader.create_data_instance(building_id[index], card_attr[index][1], card_attr[index][0])
		_place_placeable(building_instance, tilepos[index], false)
		
		#if tile_pos != NULL_TILE and building_instance.placeable(matrix_data, tilemap_to_matrix(tile_pos)):
		#matrix_data.add_placeable_to_tile(tilemap_to_matrix(tilepos[index]), building_instance)
		
		#building = Building.new_building_frm_data(building_instance)
		# NOT THE BEST SWE BUT ITS MORE EFFICIENT THIS WAY
		#if NetworkManager.is_server_client || !multiplayer.is_server():
			#terrain_tilemap.place_building_on_tile(building, tilepos[index])

################################### PLACEABLE PLACING #########################################

## Client drags card to board, calls this func to validate
@rpc("any_peer", "call_local")
func request_place_cardplaceable(placeableinst_id : String, tile_pos : Vector2i, run_on_place_events := true, sync := true) -> void:
	var remote_id : int = multiplayer.get_remote_sender_id()
	var server_mem : ServerCardMemory = (CardLoader.card_mem as ServerCardMemory)
	
	var tile_pos_matrix := tilemap_to_matrix(tile_pos)
	
	var check := server_interactability_check(remote_id, tile_pos, func() -> bool:
		# Get the carddata instance stored separately on server and client CardLoader
		var placeable_instance : PlaceableInstanceData = server_mem.search_hand_for(\
			placeableinst_id, PlayerManager.getUUID_from_PeerID(remote_id));\
		
		# Check on server side if the placeable can be place
		if placeable_instance and \
			CardLoader.event_manager.check_conditions(placeable_instance, "is_placeable", [tile_pos_matrix]):
			
			# Place on serverside
			_place_placeable(placeable_instance, tile_pos, run_on_place_events);\
			
			# Remove card from hand (serverside) now that it has been played
			server_mem.remove_card_in_hand(placeableinst_id, PlayerManager.getUUID_from_PeerID(remote_id))
			
			# If the server is client, prevent the building from being created twice 
			# Otherwise ensure the client creates its own copy
			if sync:
				_client_sync_placeable.rpc(placeable_instance.serialize(),\
						tile_pos, PlayerManager.getUUID_from_PeerID(remote_id))
			else:
				_client_sync_placeable.rpc_id(remote_id, placeableinst_id,\
					 tile_pos, PlayerManager.getUUID_from_PeerID(remote_id))
			return true;
		else:
			return false;)
	
	# The reason we dont send success check here is cuz the client needs to do its own action
	# We also dont run a function on client if the event is unsuccessful 
	if !check:
		_on_board_failed_action_by_server.rpc_id(remote_id)
		#update_client_check_status(remote_id, check)

## Used by Events to create new placeables
## Event code is in charge of making sure 
@rpc("any_peer", "call_local")
func server_place_newplaceable(placeable_instance : PlaceableInstanceData, tile_pos : Vector2i, \
	player_uuid : String, run_on_place_events := true, sync := true) -> void:
	
	if placeable_instance and CardLoader.event_manager.check_place_conditions(placeable_instance, tilemap_to_matrix(tile_pos)):
		_place_placeable(placeable_instance, tile_pos, run_on_place_events);
		
		if sync:
			_client_sync_placeable.rpc(placeable_instance.serialize(), tile_pos)
		else:
			_client_sync_placeable.rpc_id(\
				PlayerManager.getPeerID_from_UUID(player_uuid), placeable_instance.serialize(), tile_pos)

## Create a building on a given tilepos, data + visual
## Run by server + requesting client
@rpc("any_peer", "call_local")
func _place_placeable(placeable_instance: PlaceableInstanceData, tile_pos : Vector2i, run_on_place_events := true) -> void:
	var tile_pos_matrix := tilemap_to_matrix(tile_pos)

	placeable_instance.tile_pos = tile_pos_matrix
	
	if run_on_place_events and multiplayer.is_server():
		#TODO: Maybe get this out of this if
		CardLoader.event_manager.register_board_round_events(placeable_instance)

		CardLoader.event_manager.trigger_events(placeable_instance, "on_place", [tile_pos_matrix])
	
	matrix_data.add_placeable_to_tile(tile_pos_matrix, placeable_instance)

	if run_on_place_events and multiplayer.is_server():
		CardLoader.event_manager.trigger_events(placeable_instance, "post_place", [tile_pos_matrix])
		
################################# TERRAIN MODIFICATION ##########################################
#@rpc("any_peer","call_local")
#func request_create_terrain(terrain_id : String, tile_pos : Vector2i) -> void:
	#var remote_id := multiplayer.get_remote_sender_id()
	#var check := server_interactability_check(remote_id, tile_pos, func():
		#_create_terrain(terrain_id, tile_pos);\
		#
		## If the server is client, prevent the building from being created twice 
		## Otherwise ensure the client creates its own copy
		#if multiplayer.is_server() and !NetworkManager.is_client():
			#_create_terrain.rpc_id(remote_id, terrain_id, tile_pos)
		#return true;)
	#if !check:
		#_on_board_failed_action_by_server.rpc_id(remote_id)
		#update_client_check_status(remote_id, check)

@rpc("any_peer", "call_local")
func _create_terrain(terrain_id : String, tile_pos : Vector2i) -> void:
	var terrain : EnvTerrain = env_map.getTileDatabyId(terrain_id)
	matrix_data.add_tile(tilemap_to_matrix(tile_pos), terrain)

@rpc("any_peer","call_local")
func server_change_terrain(terrain_id : String, player_uuid : String, tile_pos : Vector2i, sync := true) -> void:	
	if sync:
		_change_terrain.rpc(terrain_id, tile_pos)
	else:
		_change_terrain(terrain_id, tile_pos)
		if !PlayerManager.amIPlayer(player_uuid):
			_change_terrain.rpc_id(\
				PlayerManager.getPeerID_from_UUID(player_uuid), terrain_id, tile_pos)

## Change terrain, data + visual
@rpc("any_peer","call_local")
func _change_terrain(terrain_id : String, tile_pos : Vector2i) -> void:
	var terrain : EnvTerrain = env_map.getTileDatabyId(terrain_id)
	matrix_data.change_terrain_of_tile(tile_pos, terrain)

@rpc("any_peer", "call_local")
func server_clear_tile(tile_pos : Vector2i, player_uuid : String, run_destroy_events := true, sync := true) -> void:
	#_clear_board_tile(tile_pos, run_destroy_events)
	if sync:
		_clear_board_tile.rpc(tile_pos, run_destroy_events)
	else:
		_clear_board_tile(tile_pos, run_destroy_events)
		if !PlayerManager.amIPlayer(player_uuid):
			_clear_board_tile.rpc_id(\
				PlayerManager.getPeerID_from_UUID(player_uuid), tile_pos, run_destroy_events)

@rpc("any_peer", "call_local")
func _clear_board_tile(tile_pos : Vector2i, run_destroy_events := true) -> void:
	var tile_data : BoardTile = matrix_data.get_tile(tile_pos)
	if run_destroy_events and multiplayer.is_server():
		tile_data.clear_tile(func(pi : PlaceableInstanceData):\
		CardLoader.event_manager.trigger_events(pi, "on_destroy", [tile_pos]))
	else:
		tile_data.clear_tile(func(pi : PlaceableInstanceData): pass)
		
func server_remove_building(buildinginst_id : String, player_uuid : String, run_destroy_events := true, sync := true) -> void:
	
	if sync:
		_remove_building.rpc(buildinginst_id, run_destroy_events)
	else:
		_remove_building(buildinginst_id, run_destroy_events)
		if !PlayerManager.amIPlayer(player_uuid):\
			_remove_building.rpc_id(\
			PlayerManager.getPeerID_from_UUID(player_uuid), buildinginst_id, run_destroy_events)

@rpc("any_peer", "call_local")
func _remove_building(buildinginst_id : String, run_destroy_events := true) -> void:
	var placeable_instance : PlaceableInstanceData = matrix_data.get_placeable(buildinginst_id)
	
	if run_destroy_events and multiplayer.is_server():
		CardLoader.event_manager.trigger_events(placeable_instance, "on_destroy", [placeable_instance.tile_pos])
	
	matrix_data.remove_placeable_on_tile(buildinginst_id)
	
######################################## MISC #####################################################
func server_check_tilepos_in_interactable(player_uuid : String, tilepos : Vector2i) -> bool:
	for board_layout_pos in board_layout_gen.player_interactable_boards[player_uuid]:
		if matrix_data.check_tilepos_in_layout_coords(tilepos, board_layout_pos):
			return true
	return false

func server_interactability_check(remote_id : int, tile_pos : Vector2i, upon_success : Callable) -> bool:
	if tile_pos != NULL_TILE and !SceneManager.is_gameplay_paused and server_check_tilepos_in_interactable(PlayerManager.getUUID_from_PeerID(remote_id),\
		tilemap_to_matrix(tile_pos)):
		return upon_success.call()
	else:
		return false

#func update_client_check_status(remote_id : int, result : bool) -> void:
	#if result:
		#Signalbus.emit_multiplayer_signal.rpc_id(remote_id, "board_action_failure", [])
	#else:
		#Signalbus.emit_multiplayer_signal.rpc_id(remote_id, "board_action_success", [])
	
func tilemap_to_matrix(tilemap_pos : Vector2i) -> Vector2i:
	return tilemap_pos - BORDER_DIM 

func matrix_to_tilepos(matrix_pos : Vector2i) -> Vector2i:
	return BORDER_DIM + matrix_pos
######################### CLIENT DUMMY FUNCTIONS TO OVERRIDE ################################
func receive_init_data(board_size : Vector2i, board_layout : Vector2i, border_dim : Vector2i) -> void:
	pass

func _client_create_terrain_building(data_instance : PlaceableInstanceData) -> void:
	pass

func _client_change_terrain(terrain_id : String, player_uuid : String, tile_pos : Vector2i) -> void:
	pass

@rpc("any_peer", "call_local")
func _client_sync_placeable(placeable_serialized : Dictionary, tile_pos : Vector2i, requester_uuid : String) -> void:
	pass

@rpc("any_peer", "call_local")
func _on_board_failed_action_by_server() -> void:
	pass

@rpc("any_peer", "call_local")
func client_set_interactable_board(boards: Array) -> void:
	pass

func _client_create_border_fake_tile(tid : String, tile_pos : Vector2i) -> void:
	pass

func _client_create_border_fake_building(bid : String, tile_pos : Vector2i) -> void:
	pass
