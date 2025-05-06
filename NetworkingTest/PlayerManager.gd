extends Node

var players = {}

func _ready():
	pass
	
func hasPlayer(id : int) -> bool:
	return players.has(id)

func addPlayer(id : int, name : String) -> void:
	if hasPlayer(id):
		return
	
	players[id] = {
		"id" : id,
		"name" : name,
		# Not sure if we will end up using this stat
		# for this purpose
		"score" : 0
	}

func forEachPlayer(function : Callable) -> void:
	for p in players:
		function.call(p)

func erasePlayer(id : int) -> void:
	players.erase(id)

func clearPlayers() -> void:
	players.clear()
