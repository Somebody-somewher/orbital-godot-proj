extends BoardCondition
class_name EmptyCondition

#for some power cards
func test(board : BoardMatrixData, tile_pos : Vector2i, source : CardInstanceData) -> bool:
	var placeable_arr = board.get_tile(tile_pos).placeable_arr
	return placeable_arr.is_empty()
