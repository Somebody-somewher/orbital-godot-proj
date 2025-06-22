extends Node
class_name RoundCounter
# This instance will only exist in the host. Cuz otherwise could be hacked client-side

# https://www.reddit.com/r/godot/comments/rw340d/sync_timers_in_multiplayer/
# https://www.reddit.com/r/godot/comments/rxfrxw/synchronising_timers_in_a_multiplayer_game/
# https://www.youtube.com/watch?v=TwVT3Qx9xEM

# Likelihood we can abstract these to Resource objects that just command the game objects to do stuff?
@export var initial_round : RoundState
var curr_round : RoundState
#@export var round_grp : ResourceGroup
#var possible_rounds : Array[RoundState]


# If all players indicated that they have ended their turn
# End the round prematurely
@export var players_ready : Dictionary[String, bool] = {}
var round_id : int = 0
var round_count : int = 1

# Timer 
var curr_timer : float = 0.0
var prev_s : int

var pause_timer : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signalbus.end_turn.connect(_player_end_turn)
	curr_timer = initial_round.get_time()
	prev_s = int(curr_timer)
	PlayerManager.forEachPlayer(func(pi : PlayerInfo):\
		players_ready[pi.getPlayerUUID()] = false)

	#round_grp.load_all_into(possible_rounds)
	NetworkManager.connect("all_clients_ready", start_round_manager)

func start_round_manager():
	start_round(initial_round)

func _process(delta: float) -> void:
	
	if !pause_timer:
		curr_timer -= delta
		if int(curr_timer) != prev_s:
			prev_s = int(curr_timer)
			Signalbus.emit_signal("round_timer_update", prev_s)

		if curr_timer < 0.0:
			end_round()

func _player_end_turn(player_uuid : String):
	players_ready.get_or_add(player_uuid, true)
	if false not in players_ready.values():
		end_round()
	
func end_round() -> void:
	pause_timer = true
	Signalbus.emit_signal("round_end", round_id, round_count)
	curr_round.round_end()

# In the actual game this will be called by gameplay manager after all end_of_round effects occur?
func start_round(round : RoundState) -> void:
	round.connect("transition_to", start_round)
	curr_round = round
	round_count += 1
	
	for key in players_ready.keys():
		players_ready[key] = false	
	
	reset_timer()
	
	Signalbus.emit_signal("round_start", round_id, round_count)
	curr_round.round_start()

func reset_timer() -> void:
	curr_timer = curr_round.get_time()
	prev_s = int(curr_timer)
	pause_timer = false
