extends ScoreEffect
class_name SingleTimeScoreEffect

@export var score_given : int

#deletes self to generate the score

# Actual code that uses the aoe to figure out which tiles should be scored, then assigns each tile a score
func score_tiles(_tile_pos : Vector2i) -> Array[Array]:
	return []


func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : Node2D) -> void:
	pass
