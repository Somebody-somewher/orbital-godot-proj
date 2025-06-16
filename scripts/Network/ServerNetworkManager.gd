extends Object
class_name ServerNetworkManager

var players_ready : Dictionary[int, bool] = {}
var count : int = 0
var is_syncing : bool = false

func _init() -> void:
	PlayerManager.forEachPlayer(add_players_ready)
	
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
		reset_ready()
		if !is_syncing:
			is_syncing = true			
			NetworkManager.emit_signal("all_clients_ready")
		else:
			NetworkManager.toggle_sync_finish.rpc()

func reset_ready() -> void:
	for key in players_ready.keys():
		players_ready[key] = false
	count = 0
