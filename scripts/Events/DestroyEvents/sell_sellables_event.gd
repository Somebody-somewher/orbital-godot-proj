extends BoardEvent
class_name TraderEvent

@export var tag_to_sell : String
@export var chance : float = 0.5

func preview(_board : BoardMatrixData, _previewer : Callable, _tile_pos : Vector2i, caller : CardInstanceData) -> void:
	pass

# destroys the building, #TODO building should trigger its own OnDestroyEvents
func trigger(_board : BoardMatrixData, _tile_pos : Vector2i, _caller : CardInstanceData) -> void:

	pass
