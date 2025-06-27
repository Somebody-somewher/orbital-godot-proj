extends RoundState
class_name RoundBuildState

func round_start() -> void:
	pass

func round_end() -> void:
	#Signalbus.emit_signal("server_pack_choosing_end")
	super.round_end()
	pass
