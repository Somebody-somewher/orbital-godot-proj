extends Node2D

@export var player_score := 0
@export var game_round := 1

@onready
var score_label = get_node("ScoreLabel")
@onready
var round_label = get_node("ScoreLabel")

func reset_score() -> void:
	player_score = 0
	score_label.text = "Score: " + str(player_score)

func add_score(score : int) -> void:
	player_score += score
	score_label.text = "Score: " + str(player_score)

func step_round() -> void:
	game_round += 1
	round_label.text = "Round: " + str(player_score)

# highlighting signals for cards
func connect_event_signals(event : Resource):
	event.connect("AddScore", add_score)
	pass
