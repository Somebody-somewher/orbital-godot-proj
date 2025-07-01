extends BoardEvent
class_name TimedEvent

@export var effect_when_time : BoardEvent
@export var round_count : int = 0

func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : Node2D) -> void:
	if round_count > 0:
		round_count -= 1
	elif round_count == 0:
		effect_when_time.trigger(board, tile_pos, caller)

func set_counter(n : int) :
	round_count = n
