extends Node2D

@export var player_score := 0
@export var round := 1

@onready
var score_label = get_node("ScoreLabel")
@onready
var round_label = get_node("ScoreLabel")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func reset_score() -> void:
	player_score = 0
	score_label.text = "Score: " + str(player_score)

func add_score(score : int) -> void:
	player_score += score
	score_label.text = "Score: " + str(player_score)

func step_round() -> void:
	round += 1
	round_label.text = "Round: " + str(player_score)
