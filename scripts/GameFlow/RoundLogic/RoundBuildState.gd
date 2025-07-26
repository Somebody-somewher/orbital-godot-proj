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
		transition_to.emit("END")
	else:
		transition_to.emit(next_state_ids[0])
	#super.round_end()
	Signalbus.round_end.emit(state_id, round_count)
	pass

func reset() -> void:
	
	round_count = 0
