extends Node

# Player information shouldn't be changed after initialization

var players = {}

func _ready():
	pass
	
func hasPlayer(id : int) -> bool:
	return players.has(id)

func addPlayer(id : int, name : String) -> void:
	if hasPlayer(id):
		return
	
	players[id] = PlayerInfo.new(id, name)

func forEachPlayer(function : Callable) -> Array[Variant]:
	var arr = []
	for p in players.values():
		arr.append(function.call(p))
	
	return arr

func erasePlayer(id : int) -> void:
	players.erase(id)

func clearPlayers() -> void:
	players.clear()

func getNumPlayers() -> int:
	return players.size()
