extends Condition
class_name StackableCondition

@export var layer : int = 1

func test(board : BoardMatrixData, tile_pos : Vector2i) -> bool:
	var placeable_arr = board.get_tile(tile_pos).placeable_arr
		
	for pn in placeable_arr:
		if pn.data.layer == layer:
			return false
	return true
