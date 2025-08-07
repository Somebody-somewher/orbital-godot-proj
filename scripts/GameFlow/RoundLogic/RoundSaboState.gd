extends RoundState
class_name RoundSaboState

func round_start() -> void:
	Signalbus.emit_multiplayer_signal.rpc("show_round_msg", ["Sabotage!"])
	Signalbus.set_interactable_board_state.emit(state_id)
	pass

func round_end() -> void:
	Signalbus.set_interactable_board_state.emit("build")
	#Signalbus.emit_multiplayer_signal("server_pack_choosing_end", [])
	super.round_end()
	pass
