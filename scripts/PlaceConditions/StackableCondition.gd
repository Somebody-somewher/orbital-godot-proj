extends BoardCondition
class_name StackableCondition

#@export var layer : int = 1

func test(board : BoardMatrixData, tile_pos : Vector2i, source : CardInstanceData) -> bool:
	return !board.get_tile(tile_pos).check_if_layer_occupied(source.get_data().layer)
