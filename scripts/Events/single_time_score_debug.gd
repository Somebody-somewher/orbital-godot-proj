extends Event
class_name BaseScoreEvent

func trigger(caller : CardInstanceData) -> void:
	Signalbus.emit_signal("add_score", \
		(caller as BuildingInstanceData).score, caller.get_owner_uuid())
	print((caller as BuildingInstanceData).tile_pos)
	pass
