extends BoardEvent
class_name NextTutorialEvent


func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	Signalbus.next_tutorial_stage.emit()
