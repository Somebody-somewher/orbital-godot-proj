extends BoardCondition
class_name TerrainCondition

@export var nonplaceable_terrain : Array[EnvTerrain]

func test(board : BoardMatrixData, tile_pos : Vector2i, source : CardInstanceData) -> bool:
	var current_tile_terrain : EnvTerrain = board.get_tile(tile_pos).get_terrain()
	if current_tile_terrain in nonplaceable_terrain:
		return false
	return true
