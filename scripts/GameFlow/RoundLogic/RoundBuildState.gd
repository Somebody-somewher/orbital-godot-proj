extends RoundState
class_name RoundBuildState

var round_count := 0
@export var max_round_count := -1

func round_start() -> void:
	round_count += 1
	Signalbus.round_start.emit(state_id, round_count)
	Signalbus.emit_multiplayer_signal("show_round_msg", ["Build Phase!"])
	pass

func round_end() -> void:
	if max_round_count != -1 and round_count >= max_round_count:
		emit_signal("transition_to", "END")
	else:
		emit_signal("transition_to", next_state_ids[0])
	#super.round_end()
	Signalbus.emit_signal("round_end", state_id, round_count)
	pass

func reset() -> void:
	round_count = 0
