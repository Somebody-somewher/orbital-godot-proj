extends BoardCondition
class_name StackOnSomeCondition

@export var stackable_buildings : Array[String]

func test(board : BoardMatrixData, tile_pos : Vector2i, source : CardInstanceData) -> bool:
	var placeable_arr = board.board_matrix.get_tile(tile_pos).placeable_arr
		
	for pn in placeable_arr:
		if pn.data.id_name in stackable_buildings:
			return false
	return true
