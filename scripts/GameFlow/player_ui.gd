extends Control

@export var player_score := 0

@onready var score_label = get_node("ScoreLabel")
@onready var round_timer_label = get_node("RoundTimerLabel")
@onready var round_label = get_node("RoundLabel")

@onready var round_msg: Label = $RoundMsg/Label
@onready var error_msg: Label = $ErrorMsg/ErrorLabel
@onready var error_anim: AnimationPlayer = $ErrorMsg/AnimationPlayer
@onready var round_anim: AnimationPlayer = $RoundMsg/AnimationPlayer


@onready var escape_menu: EscapeMenu = $"../EscapeMenu"

# so that players dont spam end turn
var can_end_turn := true

func _ready() -> void:
	Signalbus.connect("round_timer_update", func(time : int):
		_update_timer_ui.rpc(time))
	Signalbus.connect("round_start",_update_round_label)
	
	Signalbus.connect("show_error_msg", show_error_msg)
	Signalbus.connect("show_round_msg", show_round_msg)

	Signalbus.connect("update_score_ui", _update_score)

func reset_score() -> void:
	player_score = 0
	score_label.text = "Score: " + str(player_score)

func _update_score(score : int) -> void:
	player_score = score
	score_label.text = "Score: " + str(player_score)
	
### ROUND RELATED ###	
@rpc("any_peer", "call_local")
func _update_timer_ui(time : int) -> void:
	if time == -1:
		round_timer_label.text = "Time: inf"
	else:
		round_timer_label.text = "Time: " + str(time)

func _update_round_label(round_id : String, round_total : int) -> void:
	round_label.text = "Round: " + str(round_total)

func _on_end_turn_pressed() -> void:
	if !can_end_turn:
		return
	Signalbus.emit_multiplayer_signal.rpc_id(1, \
	"end_turn", [PlayerManager.getUUID_from_PeerID(multiplayer.get_unique_id())])
	can_end_turn= false
	await get_tree().create_timer(1).timeout
	can_end_turn= true

func show_error_msg(msg : String) -> void:
	error_msg.text = msg
	error_anim.play("show")

func show_round_msg(msg : String) -> void:
	round_msg.text = msg
	round_anim.play("pop_up")

func _input(event):
	if Input.is_action_just_pressed("escape"):
		Signalbus.close_compendium.emit()
		escape_menu.toggle()
