extends BoardEvent
class_name DestroySelfEvent


func preview(board : BoardMatrixData, previewer : Callable, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	pass
	
func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	Signalbus.remove_placeable.emit(caller.get_id(), caller.get_owner_uuid(), true)
