extends Node

# Player information shouldn't be changed after initialization

var players : Dictionary[int, PlayerInfo] = {}

func _ready():
	## TODO: Need a better system than this
	if "HostNetworking" != get_tree().current_scene.name:
		addPlayer(multiplayer.get_unique_id(), "Placeholder")
	pass
	
func hasPlayer(id : int) -> bool:
	return players.has(id)

func addPlayer(id : int, name : String) -> void:
	players.get_or_add(id, PlayerInfo.new(id, name))
	
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
