extends Condition
class_name BoardHasCondition

@export var id_name : String
@export var count_needed : int = 1

var _count_current := 0

#checks if the entire board contains at least X amount of such placeable
func test(board : Board, tile_pos : Vector2i) -> bool:
	_count_current = 0
	board.board_matrix.for_each_tile(count_building, [])
	return _count_current >= count_needed

func count_building(tile : BoardTile):
	for pn in tile.placeable_arr:
		if pn.data.id_name == id_name:
			_count_current += 1
	
