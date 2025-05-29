extends Node
class_name RoundCounter
# This instance will only exist in the host. Cuz otherwise could be hacked client-side

# https://www.reddit.com/r/godot/comments/rw340d/sync_timers_in_multiplayer/
# https://www.reddit.com/r/godot/comments/rxfrxw/synchronising_timers_in_a_multiplayer_game/
# https://www.youtube.com/watch?v=TwVT3Qx9xEM

# Likelihood we can abstract these to Resource objects that just command the game objects to do stuff?
@export var rounds = [["pick_round", 10.0], ["build_round", 30.0]]


# If all players indicated that they have ended their turn
# End the round prematurely
@export var players_ready : Array[bool] = [false]
var round_id : int = 0
var round_count : int = 1

# Timer 
var curr_timer : float = 0.0
var prev_s : int

var pause_timer : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signalbus.end_turn.connect(_player_end_turn)
	curr_timer = rounds[0][1]
	prev_s = int(curr_timer)

func _process(delta: float) -> void:
	
	if !pause_timer:
		curr_timer -= delta
		if int(curr_timer) != prev_s:
			prev_s = int(curr_timer)
			Signalbus.emit_signal("round_timer_update", prev_s)

		if curr_timer < 0.0:
			end_round()

func _player_end_turn(player_id : int):
	players_ready[player_id] = true
	if false not in players_ready:
		end_round()
	
func end_round() -> void:
	players_ready = [false]
	pause_timer = true
	Signalbus.emit_signal("round_end", round_id, round_count)

# In the actual game this will be called by gameplay manager after all end_of_round effects occur?
func start_round() -> void:
	round_id += 1
	round_id %= len(rounds)
	
	round_count += 1
	players_ready = [false]
	reset_timer()
	Signalbus.emit_signal("round_start", round_id, round_count)

func reset_timer() -> void:
	curr_timer = rounds[round_id][1]
	prev_s = int(curr_timer)
	pause_timer = false
	
