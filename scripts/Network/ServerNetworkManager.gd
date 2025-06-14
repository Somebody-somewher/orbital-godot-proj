extends Object
class_name ServerNetworkManager

var players_ready : Dictionary[int, bool] = {}
var count : int = 0

func _init() -> void:
	PlayerManager.forEachPlayer(add_players_ready)
	
func add_players_ready(pi : PlayerInfo) -> void:
	players_ready.get_or_add(pi.getPlayerId(), false)

func mark_player_as_ready(multiplayer_id : int) -> void:
	if players_ready[multiplayer_id] == false:
		count += 1 
		players_ready[multiplayer_id] = true
	
	print("READY COUNT ", count, " ", players_ready)
	if count == len(players_ready):
		NetworkManager.emit_signal("all_clients_ready")
	
func reset_ready() -> void:
	for key in players_ready.keys():
		players_ready[key] = false
