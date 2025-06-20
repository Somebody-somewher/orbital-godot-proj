extends Node

# Player information shouldn't be changed after initialization

var peerid_to_players : Dictionary[int, PlayerInfo] = {}
var uuid_to_players : Dictionary[String, PlayerInfo] = {}

func _ready():
	## TODO: Need a better system than this
	# Creates a "fake" single player for singleplayer
	if "HostNetworking" != get_tree().current_scene.name:
		addPlayer("Placeholder", multiplayer.get_unique_id(), "Placeholder")
	pass
	
func hasPlayer(peer_id : int) -> bool:
	return peerid_to_players.has(peer_id)

func addPlayer(uuid : String, peer_id : int, name : String) -> void:
	var player_info : PlayerInfo = PlayerInfo.new(uuid, peer_id, name)
	peerid_to_players.get_or_add(peer_id, player_info)
	uuid_to_players.get_or_add(uuid, player_info)

# Assumes new peerid isnt a repeat of some other peerid 
func reconnectPlayer(uuid : String, new_id : int) -> void:
	peerid_to_players.erase(uuid_to_players[uuid].getPlayerId())
	uuid_to_players[uuid].changePlayerId(new_id)
	peerid_to_players.get_or_add(new_id, uuid_to_players[uuid])
	
func forEachPlayer(function : Callable) -> Array[Variant]:
	var arr = []
	for p in peerid_to_players.values():
		arr.append(function.call(p))
	
	return arr

func erasePlayer(id : int) -> void:
	peerid_to_players.erase(id)

func clearPlayers() -> void:
	peerid_to_players.clear()
	uuid_to_players.clear()
	
func getNumPlayers() -> int:
	return peerid_to_players.size()

func getPeerID_from_UUID(uuid : String) -> int:
	return uuid_to_players[uuid].getPlayerId()

func getUUID_from_PeerID(peer_id : int) -> String:
	return peerid_to_players[peer_id].getPlayerUUID()

func getCurrentPlayerUUID() -> String:
	return peerid_to_players[multiplayer.get_unique_id()].getPlayerUUID()

func getPeerIDs() -> Array[int]:
	return peerid_to_players.keys()
