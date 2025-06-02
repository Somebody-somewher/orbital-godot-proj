extends Node2D

@export var meowSpawner : PackedScene
# https://www.youtube.com/watch?v=AytWpymeVJw
@export var manager : PackedScene

func _ready() -> void:
	#add_child(s)
	var spawners = PlayerManager.forEachPlayer(createSpawner)
	
	for s in spawners:
		add_child(s)
	
	if multiplayer.is_server():		
		add_child(manager.instantiate())
		


func createSpawner(pi : PlayerInfo) -> Node2D:
	var meowSpawner = meowSpawner.instantiate()
	# TODO: Prolly not the best way to do this, but it works for now
	meowSpawner.name = str(pi.getPlayerId())
	return meowSpawner
	
