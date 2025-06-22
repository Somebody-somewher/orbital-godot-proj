extends RoundState
class_name RoundChoosePackState

func round_start() -> void:
	Signalbus.emit_signal("server_create_packs")
	pass

func round_end() -> void:
	Signalbus.emit_signal("server_pack_choosing_end")
	super.round_end()
	pass
