extends Control

@export var player_score := 0

@onready
var score_label = get_node("ScoreLabel")
@onready
var round_timer_label = get_node("RoundTimerLabel")
@onready
var round_label = get_node("RoundLabel")

func _ready() -> void:
	Signalbus.connect("round_timer_update",_update_timer_ui)
	Signalbus.connect("round_start",_update_round_label)


func reset_score() -> void:
	player_score = 0
	score_label.text = "Score: " + str(player_score)

func add_score(score : int) -> void:
	player_score += score
	score_label.text = "Score: " + str(player_score)

# highlighting signals for cards
func connect_event_signals(event : Resource):
	event.connect("AddScore", add_score)
	pass


### ROUND RELATED ###
func _update_timer_ui(time : int) -> void:
	round_timer_label.text = "Time: " + str(time)

func _update_round_label(round_id : int, round_total : int) -> void:
	round_label.text = "Round: " + str(round_id + 1)

func _on_end_turn_pressed() -> void:
	Signalbus.emit_signal("end_turn", 0)
	pass # Replace with function body.
