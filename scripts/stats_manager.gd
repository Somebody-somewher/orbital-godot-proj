extends Node2D

@export var player_score := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func reset_score() -> void:
	player_score = 0

func add_score(score : int) -> void:
	player_score += score
