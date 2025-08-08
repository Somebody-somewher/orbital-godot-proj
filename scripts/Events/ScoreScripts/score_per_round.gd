extends ScoreEffect
class_name PassiveScoreEffect

@export var score_per_round : int
#generate x score every round

## Actual code that uses the aoe to figure out which tiles should be scored, then assigns each tile a score
#func score_tiles(_tile_pos : Vector2i) -> Array[Array]:
	#return []
#
func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	Signalbus.emit_signal("add_score", score_per_round, caller.get_owner_uuid())
	Signalbus.call_point_fx.emit(score_per_round, tile_pos, caller.get_owner_uuid(), tile_pos)
