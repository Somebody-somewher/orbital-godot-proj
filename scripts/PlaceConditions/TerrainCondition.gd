extends Condition
class_name TerrainCondition

@export var terrain_type : String

func test(board : Board, tile_pos : Vector2i) -> bool:
	return true
