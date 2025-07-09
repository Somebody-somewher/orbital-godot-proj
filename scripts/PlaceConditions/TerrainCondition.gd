extends BoardCondition
class_name TerrainCondition

@export var terrain_type : String

func test(board : BoardMatrixData, tile_pos : Vector2i, source : CardInstanceData) -> bool:
	if board.get_tile(tile_pos).get_terrain() in (source.get_data() as BuildingData).nonplaceable_terrain:
		return false
	return true
