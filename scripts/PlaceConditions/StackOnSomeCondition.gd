extends StackableCondition
class_name StackOnlyOnCondition

@export var stackable_buildings : Array[String]


#can stack only on listed buildings
func test(board : BoardMatrixData, tile_pos : Vector2i, source : CardInstanceData) -> bool:
	var placeable_arr = board.get_tile(tile_pos).placeable_arr
		
	for pn in placeable_arr:
		if pn and pn.data.id_name in stackable_buildings:
			return true
	return false
