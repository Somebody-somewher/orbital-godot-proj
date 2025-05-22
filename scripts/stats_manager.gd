extends Node2D

@export var player_score := 0

@onready
var score_label = get_node("ScoreLabel")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func reset_score() -> void:
	player_score = 0
	score_label.text = str(player_score)

func add_score(score : int) -> void:
	player_score += score
	score_label.text = str(player_score)
