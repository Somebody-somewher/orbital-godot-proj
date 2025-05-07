extends Node2D

@export var meowSpawner : PackedScene
# https://www.youtube.com/watch?v=AytWpymeVJw

func _ready() -> void:
	#var s = createSpawner(PlayerInfo.new(1, "TEST"))
	#add_child(s)
	var spawners = PlayerManager.forEachPlayer(createSpawner)
	for s in spawners:
		add_child(s)



func createSpawner(pi : PlayerInfo) -> Node2D:
	var meowSpawner = meowSpawner.instantiate()
	# TODO: Prolly not the best way to do this, but it works for now
	meowSpawner.name = str(pi.getPlayerId())
	return meowSpawner
	
