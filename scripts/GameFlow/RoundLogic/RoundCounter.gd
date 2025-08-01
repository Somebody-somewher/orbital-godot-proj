extends Node
class_name RoundCounter
# This instance will only exist in the host. Cuz otherwise could be hacked client-side

# https://www.reddit.com/r/godot/comments/rw340d/sync_timers_in_multiplayer/
# https://www.reddit.com/r/godot/comments/rxfrxw/synchronising_timers_in_a_multiplayer_game/
# https://www.youtube.com/watch?v=TwVT3Qx9xEM

# Likelihood we can abstract these to Resource objects that just command the game objects to do stuff?
@export var initial_round : RoundState
var curr_round : RoundState


# If all players indicated that they have ended their turn
# End the round prematurely
@export var players_ready : Dictionary[String, bool] = {}

# Prevent glitch where player can press the end turn button when round is already ending
var is_round_ending := false
var round_num_game_end : int = -1

var score_manager : ScoreManager
var is_game_ended := false

# Timer-related
var curr_timer : float = 0.0
var prev_s : int
var pause_timer : bool = false


@export var round_id_lookup : Dictionary[String, RoundState]

@export var end_game_wait := 25.0

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#Signalbus.end_turn.connect(_player_end_turn)
	#curr_timer = initial_round.get_time()
	#prev_s = int(curr_timer)
	#PlayerManager.forEachPlayer(func(pi : PlayerInfo):\
		#players_ready[pi.getPlayerUUID()] = false)
	#
	#score_manager = ScoreManager.new()
	#score_manager.connect("game_end", end_game)
#
	#for round in round_id_lookup.values():
		#round.connect("transition_to", start_round)
	#
	##round_grp.load_all_into(possible_rounds)
	#NetworkManager.connect("all_clients_ready", start_round_manager)
	#NetworkManager.server_net.mark_server_component_ready(self.name)
# Called when the node enters the scene tree for the first time.

func set_up(settings : Dictionary) -> void:
	Signalbus.end_turn.connect(_player_end_turn)
	Signalbus.reset_scene.connect(reset)
	curr_timer = initial_round.get_time()
	prev_s = int(curr_timer)
	PlayerManager.forEachPlayer(func(pi : PlayerInfo):\
		players_ready[pi.getPlayerUUID()] = false)
	
	if settings.has('win_rounds'):
		round_num_game_end = settings['win_rounds']
	
	score_manager = ScoreManager.new(settings)
	score_manager.game_end.connect(end_game)

	for round in round_id_lookup.values():
		round.transition_to.connect(start_round)
	
	#round_grp.load_all_into(possible_rounds)
	NetworkManager.connect("all_clients_ready", start_round_manager)
	
	# NOTE: If this produces an error, check NetworkManager debug is set to true
	NetworkManager.server_net.mark_server_component_ready(self.name)

func start_round_manager():
	start_round(initial_round.get_id())

func _process(delta: float) -> void:
	
	if !pause_timer:
		curr_timer -= delta
		if int(curr_timer) != prev_s:
			prev_s = int(curr_timer)
			Signalbus.emit_signal("round_timer_update", prev_s)

		if curr_timer < 0.0:
			end_round()

func _player_end_turn(player_uuid : String):
	players_ready[player_uuid] = true
	if !is_round_ending and false not in players_ready.values():
		end_round()
	
func end_round() -> void:
	pause_timer = true
	score_manager.set_is_poll_first(true)
	#Signalbus.emit_signal("round_end", round_id, round_count)
	is_round_ending = true
	curr_round.round_end()
	score_manager.set_is_poll_first(false)
	score_manager.query_for_winner(false)

# In the actual game this will be called by gameplay manager after all end_of_round effects occur?
func start_round(round_id : String) -> void:
	
	if round_id == "END":
		score_manager.query_for_winner(true)
		return
	
	curr_round = round_id_lookup[round_id]
	
	for key in players_ready.keys():
		players_ready[key] = false	
	
	is_round_ending = false
	
	reset_timer()
	
	#Signalbus.emit_signal("round_start", round_id, round_count)
	score_manager.set_is_poll_first(true)
	curr_round.round_start()
	score_manager.set_is_poll_first(false)
	score_manager.query_for_winner(false)

func reset_timer() -> void:
	curr_timer = curr_round.get_time()
	prev_s = int(curr_timer)
	pause_timer = false

func end_game(rankings : Array[String], player_scores : Dictionary[String, Dictionary]) -> void:
	if !is_game_ended:
		pause_timer = true
		is_game_ended = true
		SceneManager.pause_everything.rpc()
		Signalbus.emit_multiplayer_signal.rpc("end_game", [rankings, player_scores])
		await get_tree().create_timer(end_game_wait).timeout
		SceneManager.back_to_menu.rpc()
	pass

func reset() -> void:
	score_manager.game_end.disconnect(end_game)
	for state in round_id_lookup.values():
		state.reset()
		state.transition_to.disconnect(start_round)
