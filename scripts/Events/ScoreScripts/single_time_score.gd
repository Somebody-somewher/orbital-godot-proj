extends ScoreEffect
class_name SingleTimeScoreEvent

@export var score_given : int

func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	Signalbus.call_point_fx.emit(score_given, tile_pos, caller.get_owner_uuid(), tile_pos)
	Signalbus.add_score.emit(score_given, caller.get_owner_uuid())
