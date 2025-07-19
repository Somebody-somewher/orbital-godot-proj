extends RoundState
class_name RoundBuildState

func round_start() -> void:
	pass

func round_end() -> void:
	if update_round_count.call():
		emit_signal("transition_to", "END")
	else:
		emit_signal("transition_to", next_state_ids[0])
	#super.round_end()
	pass
