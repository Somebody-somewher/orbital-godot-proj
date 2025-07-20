extends Event 
class_name BoardEvent

@export var aoe : AOE

# caller cn be a card that plays animation, or a building that needs moifying
func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	pass

func preview(_board : BoardMatrixData, _previewer : Callable, _tile_pos : Vector2i, caller : CardInstanceData) -> void:
	pass
