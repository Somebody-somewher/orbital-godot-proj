extends Node
# Directs flow of the game. Separate from the RoundManager. 
# Likely the GameManager will need to take control to pause game flow to show animations 
# or pause the game whenever a player disconnects 
@export
var round_manager : RoundCounter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Eventbus.round_end.connect(_pick_round)
	pass # Replace with function body.

func _pick_round(round_id : int, round_total : int) -> void:
	round_manager.start_round()
