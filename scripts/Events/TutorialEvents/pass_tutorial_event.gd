extends BoardEvent
class_name PassTutorialEvent


func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	Signalbus.pass_tutorial_stage.emit()
