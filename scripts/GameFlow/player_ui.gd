extends CanvasLayer

@export var player_score := 0

@onready
var score_label = get_node("ScoreLabel")
@onready
var round_timer_label = get_node("RoundTimerLabel")
@onready
var round_label = get_node("RoundLabel")

func _ready() -> void:
	Signalbus.connect("round_timer_update", func(time : int):
		_update_timer_ui.rpc(time))
	Signalbus.connect("round_start",_update_round_label)

	# TODO: See if this needs removing later
	Signalbus.connect("add_score", add_score)

func reset_score() -> void:
	player_score = 0
	score_label.text = "Score: " + str(player_score)

func add_score(score : int) -> void:
	player_score += score
	score_label.text = "Score: " + str(player_score)
	
### ROUND RELATED ###	
@rpc("authority", "call_local")
func _update_timer_ui(time : int) -> void:
	round_timer_label.text = "Time: " + str(time)

func _update_round_label(round_id : int, round_total : int) -> void:
	round_label.text = "Round: " + str(round_id + 1)

func _on_end_turn_pressed() -> void:
	Signalbus.emit_signal("end_turn", 0)
	pass # Replace with function body.
