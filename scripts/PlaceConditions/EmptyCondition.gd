extends BoardCondition
class_name EmptyCondition

#for some power cards
func test(board : BoardMatrixData, tile_pos : Vector2i, source : CardInstanceData) -> bool:
	return board.get_tile(tile_pos).is_empty()
