extends ScoreEffect
class_name BoardCountScoreEffect


# Actual code that uses the aoe to figure out which tiles should be scored, then assigns each tile a score
func score_tiles(_tile_pos : Vector2i) -> Array[Array]:
	return []

# Displays the textlabel scoring above each tile. Board calls this function during preview_placement
# Note that this does not finalize the scoring
func preview(board : BoardMatrixData, previewer : Callable, tile_pos : Vector2i) -> void:
	pass

func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : Node2D) -> void:
	#for each pair in dictionary, count number on board and score for each one
	pass
