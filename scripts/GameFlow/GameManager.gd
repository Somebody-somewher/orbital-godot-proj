extends Node
# Directs flow of the game. Separate from the RoundManager. 
# Likely the GameManager will need to take control to pause game flow to show animations 
# or pause the game whenever a player disconnects 
@export var round_manager : RoundCounter

# Send this to RoundManager via Callable
@export var card_pack_manager : CardPackManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signalbus.round_end.connect(_pick_round)
	AudioManager.play_bgm("plains")

func _pick_round(round_id : int, round_total : int) -> void:
	#if round_id == 1:
		#card_pack_manager.create_pack()
	round_manager.start_round()
