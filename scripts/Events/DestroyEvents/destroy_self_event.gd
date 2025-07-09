extends BoardEvent
class_name MoveWRangeEvent

@export var attractor : String
@export var detector_aoe : AOE

#if there are attractors nearby, move towards it randomly

func preview(board : BoardMatrixData, previewer : Callable, tile_pos : Vector2i) -> void:
	pass

func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	pass
	
