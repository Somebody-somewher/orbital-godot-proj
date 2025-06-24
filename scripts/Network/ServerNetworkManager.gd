extends Object
class_name ServerNetworkManager

var players_ready : Dictionary[int, bool] = {}
var server_components : Dictionary[String,bool] = {}

var count : int = 0
var is_syncing := false
var all_clients_ready := false


func _init(server_comp : Dictionary[String, bool]) -> void:
	PlayerManager.forEachPlayer(add_players_ready)
	server_components = server_comp
	
func add_players_ready(pi : PlayerInfo) -> void:
	players_ready.get_or_add(pi.getPlayerId(), false)

func mark_player_as_ready(multiplayer_id : int) -> void:
	if players_ready[multiplayer_id] == false:
		count += 1 
		players_ready[multiplayer_id] = true
	
	print("READY COUNT ", count, " ", players_ready)
	
	# All clients ready signal is to check all client nodes are loaded in
	# Before server sends data
	# The other is to confirm that the system is synced up (will happen multiple times in course of game)
	if count == len(players_ready):
		if !is_syncing:
			is_syncing = true
			all_clients_ready = true
			attempt_signal()
		else:
			reset_ready()
			NetworkManager.toggle_sync_finish.rpc()

func mark_server_component_ready(component_name : String) -> void:
	server_components[component_name] = true
	attempt_signal()
		
func attempt_signal() -> void:
	if all_clients_ready and false not in server_components.values():
		reset_ready()
		NetworkManager.emit_signal("all_clients_ready")


func reset_ready() -> void:
	for key in players_ready.keys():
		players_ready[key] = false
		
	for key in server_components.keys():
		server_components[key] = false
	
	all_clients_ready = false
	count = 0
