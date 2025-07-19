extends Node

# Player information shouldn't be changed after initialization

var peerid_to_players : Dictionary[int, PlayerInfo] = {}
var uuid_to_players : Dictionary[String, PlayerInfo] = {}

var player_colors : Array[Color] = [Color.PINK, Color.LIGHT_SALMON, Color.AZURE, Color.AQUAMARINE]
var color_index := 0

@export var is_multiplayer : bool = false

func _ready():
	## TODO: Need a better system than this
	# Creates a "fake" single player for singleplayer
	if !is_multiplayer:
		addPlayer("PlaceholderPlayerUUID", multiplayer.get_unique_id(), "PlaceholderPlayer")
	pass

func declare_multiplayer() -> void:
	is_multiplayer = true
	erasePlayerbyUUID("PlaceholderPlayerUUID")

func hasPlayer(peer_id : int) -> bool:
	return peerid_to_players.has(peer_id)

func hasPlayerUUID(player_uuid : String) -> bool:
	return uuid_to_players.has(player_uuid)

func addPlayer(uuid : String, peer_id : int, player_name : String) -> void:
	var player_info : PlayerInfo = PlayerInfo.new(uuid, peer_id, player_name, player_colors[color_index])
	color_index += 1
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

@rpc("call_local", "any_peer")
func erasePlayer(id : int) -> void:
	if hasPlayer(id):
		uuid_to_players.erase(peerid_to_players[id].getPlayerUUID())
		peerid_to_players.erase(id)

@rpc("call_local", "any_peer")
func erasePlayerbyUUID(uuid : String) -> void:
	if hasPlayerUUID(uuid):
		peerid_to_players.erase(uuid_to_players[uuid].getPlayerId())
		uuid_to_players.erase(uuid)
	
@rpc("call_local", "any_peer")
func clearPlayers() -> void:
	peerid_to_players.clear()
	uuid_to_players.clear()
	
func getNumPlayers() -> int:
	return peerid_to_players.size()

func getPeerID_from_UUID(uuid : String) -> int:
	return uuid_to_players[uuid].getPlayerId()

func getUUID_from_PeerID(peer_id : int) -> String:
	return peerid_to_players[peer_id].getPlayerUUID()

func getPlayerName_from_UUID(uuid : String) -> String:
	return uuid_to_players[uuid].getPlayerName()

func getCurrentPlayerUUID() -> String:
	return peerid_to_players[multiplayer.get_unique_id()].getPlayerUUID()

func getCurrentPlayerName() -> String:
	return peerid_to_players[multiplayer.get_unique_id()].getPlayerName()

func getPeerIDs() -> Array[int]:
	return peerid_to_players.keys()

func amIPlayer(peer_uuid : String) -> bool:
	return peer_uuid == peerid_to_players[multiplayer.get_unique_id()].getPlayerUUID()
	
func reset() -> void:
	clearPlayers()
	color_index = 0
	is_multiplayer = false
