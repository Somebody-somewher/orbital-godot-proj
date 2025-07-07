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

@export var terrain_tilemap : BoardVisualManager
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

## This is run by the server to supply data to all clients
## Signal-activated by NetworkManager "all_clients_ready"
func init_clients() -> void:
	receive_init_data.rpc(BOARD_SIZE, BOARDS_LAYOUT, BORDER_DIM)
	procgen_init(func(tid : String, tile_pos : Vector2i): _create_terrain.rpc(tid, tile_pos) \
	, func(tid : String, tile_pos : Vector2i): terrain_tilemap.change_border_terrain_tile.rpc(tid, tile_pos) \
	, create_terrain_building \
	, func(bid : String, tile_pos : Vector2i): terrain_tilemap.place_fake_building.rpc(bid, tile_pos))
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
		
		var placeholder_id = terrain_tilemap.env_map.getPlaceholderTile().get_id()
		for x in range(BOARD_SIZE.x * BOARDS_LAYOUT.x):
			for y in range(BOARD_SIZE.y * BOARDS_LAYOUT.y):
				create_terrain.call(placeholder_id, Vector2i(x,y))

func _ready() -> void:
	# Server setup code
	if multiplayer.is_server():
		# Signal telling server that all clients are ready to receive info
		NetworkManager.connect("all_clients_ready", init_clients)
		board_layout_gen = BoardLayout.new(func(player_id : int, boards : Array): \
		set_interactable_board.rpc_id(player_id, boards))
		
		BOARDS_LAYOUT = board_layout_gen.get_board_layout(PlayerManager.getNumPlayers())
		if proc_gen != null:
			proc_gen.set_up(BOARD_SIZE, BOARDS_LAYOUT, BORDER_DIM)

func receive_init_data(board_size : Vector2i, board_layout : Vector2i, border_dim : Vector2i) -> void:
	pass

############################### INITIAL PROCGEN FUNCTIONS ####################################
@rpc("any_peer", "call_local")
func _create_terrain_building(building_id: Array[String], tilepos: Array[Vector2i], card_attr : Array) -> void:
	var building_instance : BuildingInstanceData
	var building : Building
	for index in range(len(card_attr)):
		building_instance = CardLoader.create_data_instance(building_id[index], card_attr[index][1], card_attr[index][0])
		#if tile_pos != NULL_TILE and building_instance.placeable(matrix_data, tilemap_to_matrix(tile_pos)):

		building = Building.new_building_frm_data(building_instance)
		matrix_data.add_placeable_to_tile(tilemap_to_matrix(tilepos[index]), building)
		
		# NOT THE BEST SWE BUT ITS MORE EFFICIENT THIS WAY
		if NetworkManager.is_server_client || !multiplayer.is_server():
			terrain_tilemap.place_building_on_tile(building, tilepos[index])
	

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

################################### PLACEABLE PLACING #########################################
@rpc("any_peer", "call_local")
func request_place_cardplaceable(placeableinst_id : String, tile_pos : Vector2i) -> void:
	var remote_id : int = multiplayer.get_remote_sender_id()
	var check := server_check(remote_id, tile_pos, func() -> bool:
		# Get the carddata instance stored separately on server and client CardLoader
		var placeable_instance : PlaceableInstanceData = (CardLoader.card_mem as ServerCardMemory).attempt_to_use_hand_card(\
			placeableinst_id, PlayerManager.getUUID_from_PeerID(remote_id));\
		
		# Check on server side if the placeable can be place
		if placeable_instance: #and placeable_instance.placeable(matrix_data, tilemap_to_matrix(tile_pos)):
			
			# Place on serverside
			_place_placeable(placeable_instance, tile_pos);\
			
			# If the server is client, prevent the building from being created twice 
			# Otherwise ensure the client creates its own copy
			if !NetworkManager.is_server_client:
				client_place_cardplaceable.rpc_id(remote_id, placeableinst_id, tile_pos)
			
			
			
			return true;
		else:
			return false;)
	
	# The reason we dont send success check here is cuz the client needs to do its own action
	# We also dont run a function on client if the event is unsuccessful 
	if !check:
		_on_board_failed_action_by_server.rpc_id(remote_id)
		#update_client_check_status(remote_id, check)
	
#@rpc("any_peer", "call_local")
#func request_place_cardplaceable(placeableinst_id : String, tile_pos : Vector2i) -> void:
	#var remote_id : int = multiplayer.get_remote_sender_id()
	#var player_requesting_id = PlayerManager.getUUID_from_PeerID(multiplayer.get_remote_sender_id())
	#if tile_pos != NULL_TILE and check_tilepos_in_interactable(PlayerManager.getUUID_from_PeerID(remote_id), tile_pos):
		#var placeable_instance : PlaceableInstanceData = CardLoader.server_card_memory.search_hand_for(player_requesting_id, placeableinst_id)
		#if placeable_instance and placeable_instance.placeable(matrix_data, tilemap_to_matrix(tile_pos)):
			#_place_placeable(placeable_instance, tile_pos)
			#if multiplayer.is_server() and !NetworkManager.is_client():
				#client_place_cardplaceable.rpc_id(remote_id, placeableinst_id, tile_pos)
	#Signalbus.emit_multiplayer_signal.rpc_id(remote_id, "board_action_failure")

@rpc("any_peer", "call_local")
func client_place_cardplaceable(placeableinst_id : String, tile_pos : Vector2i) -> void:
	pass
	
## Create a building on a given tilepos, data + visual
## Run by server + requesting client
@rpc("any_peer", "call_local")
func _place_placeable(placeable_instance: PlaceableInstanceData, tile_pos : Vector2i) -> PlaceableNode:
	var placeable_node : PlaceableNode
	if placeable_instance is BuildingInstanceData:
		placeable_node = Building.new_building_frm_data(placeable_instance as BuildingInstanceData)
	
	# TODO: CHANGE THIS from NODE
	# PROBABLY NEED A SIGNAL INSTEAD
	#placeable_node.trigger_place_effects(matrix_data, tilemap_to_matrix(tile_pos))
	
	matrix_data.add_placeable_to_tile(tilemap_to_matrix(tile_pos), placeable_node)
	return placeable_node

################################# TERRAIN MODIFICATION ##########################################
@rpc("any_peer","call_local")
func request_create_terrain(terrain_id : String, tile_pos : Vector2i) -> void:
	var remote_id := multiplayer.get_remote_sender_id()
	var check := server_check(remote_id, tile_pos, func():
		_create_terrain(terrain_id, tile_pos);\
		
		# If the server is client, prevent the building from being created twice 
		# Otherwise ensure the client creates its own copy
		if multiplayer.is_server() and !NetworkManager.is_client():
			_create_terrain.rpc_id(remote_id, terrain_id, tile_pos)
		return true;)
	if !check:
		_on_board_failed_action_by_server.rpc_id(remote_id)
		#update_client_check_status(remote_id, check)

@rpc("any_peer", "call_local")
func _create_terrain(terrain_id : String, tile_pos : Vector2i) -> void:
	var terrain : EnvTerrain = terrain_tilemap.env_map.getTileDatabyId(terrain_id)
	matrix_data.add_tile(tilemap_to_matrix(tile_pos), terrain)

@rpc("any_peer","call_local")
func request_change_terrain(terrain_id : String, tile_pos : Vector2i) -> void:
	var remote_id := multiplayer.get_remote_sender_id()
	var check := server_check(remote_id, tile_pos, func():
		_create_terrain(terrain_id, tile_pos);\

		# If the server is client, prevent the building from being created twice 
		# Otherwise ensure the client creates its own copy
		if multiplayer.is_server() and !NetworkManager.is_client():
			_change_terrain.rpc_id(remote_id, terrain_id, tile_pos)
		return true;)

	if !check:
		_on_board_failed_action_by_server.rpc_id(remote_id)
	#update_client_check_status(remote_id, check)

## Change terrain, data + visual
@rpc("any_peer","call_local")
func _change_terrain(terrain_id : String, tile_pos : Vector2i) -> void:
	var terrain : EnvTerrain = terrain_tilemap.env_map.getTileDatabyId(terrain_id)
	matrix_data.change_terrain_of_tile(tile_pos, terrain)

@rpc("any_peer", "call_local")
func remove_building(tile_pos : Vector2i = NULL_TILE) -> void:
	pass

######################################## MISC #####################################################
func check_tilepos_in_interactable(player_uuid : String, tilepos : Vector2i) -> bool:
	for board_layout_pos in board_layout_gen.player_interactable_boards[player_uuid]:
		if matrix_data.check_tilepos_in_layout_coords(tilepos, board_layout_pos):
			return true
	return false

func server_check(remote_id : int, tile_pos : Vector2i, upon_success : Callable) -> bool:
	if tile_pos != NULL_TILE and check_tilepos_in_interactable(PlayerManager.getUUID_from_PeerID(remote_id), tile_pos):
		return upon_success.call()
	else:
		return false

#func update_client_check_status(remote_id : int, result : bool) -> void:
	#if result:
		#Signalbus.emit_multiplayer_signal.rpc_id(remote_id, "board_action_failure", [])
	#else:
		#Signalbus.emit_multiplayer_signal.rpc_id(remote_id, "board_action_success", [])

func _on_board_failed_action_by_server() -> void:
	pass

## Shade and unshade the individual boards that are interactable
func set_interactable_board(boards: Array) -> void:
	pass
		
func tilemap_to_matrix(tilemap_pos : Vector2i) -> Vector2i:
	return tilemap_pos - BORDER_DIM 

func matrix_to_tilepos(matrix_pos : Vector2i) -> Vector2i:
	return BORDER_DIM + matrix_pos
