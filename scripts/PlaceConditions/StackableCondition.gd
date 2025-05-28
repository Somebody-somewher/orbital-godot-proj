extends Condition
class_name StackableCondition

func test(_board_matrix, _tile_pos : Vector2i) -> bool:
	var arr : Array[Building] = _board_matrix.get_tile(_tile_pos).buildings
	if len(arr) >= 1:
		return _board_matrix.get_tile(_tile_pos).buildings[0].data.stackable
	return true
