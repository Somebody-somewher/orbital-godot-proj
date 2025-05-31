extends BoardEvent
class_name TimedEffect

var effect_when_time : BoardEvent
var round_count : int = 0

func trigger(board_matrix, tile_pos : Vector2i) -> void:
	if round_count > 0:
		round_count -= 1
	elif round_count == 0:
		effect_when_time.trigger(board_matrix, tile_pos)

func set_counter(n : int) :
	round_count = n
