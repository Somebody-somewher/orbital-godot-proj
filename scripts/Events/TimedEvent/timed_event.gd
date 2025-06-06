extends BoardEvent
class_name TimedEvent

var effect_when_time : BoardEvent
var round_count : int = 0

func trigger(board_matrix, tile_pos : Vector2i, caller : Object) -> void:
	if round_count > 0:
		round_count -= 1
	elif round_count == 0:
		effect_when_time.trigger(board_matrix, tile_pos, caller)

func set_counter(n : int) :
	round_count = n
