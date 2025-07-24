extends BoardCondition
class_name NotEmptyCondition

#for some power cards
func test(board : BoardMatrixData, tile_pos : Vector2i, source : CardInstanceData) -> bool:
	var placeable_arr = board.board_matrix.get_tile(tile_pos).placeable_arr
	if placeable_arr.is_empty():
		return false
	return true
