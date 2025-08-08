extends BoardEvent
class_name EndTutorialEvent


func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	Signalbus.end_tut.emit()
