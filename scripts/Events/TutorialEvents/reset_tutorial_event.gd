extends BoardEvent
class_name ResetTutorialEvent


func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	Signalbus.reset_tutorial.emit()
