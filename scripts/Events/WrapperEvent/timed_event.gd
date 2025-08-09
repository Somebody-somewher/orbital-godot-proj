extends BoardEvent
class_name TimedEvent
#
@export var effects_when_time : Array[BoardEvent]
@export var round_count : int = 0

func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	if round_count > 0:
		round_count -= 1
	elif round_count == 0:
		for e in effects_when_time:
			e.trigger(board, tile_pos, caller)
#
#func set_counter(n : int) :
	#round_count = n
