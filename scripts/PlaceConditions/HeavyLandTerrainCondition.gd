extends BoardCondition
class_name HeavyLandTerrainCondition

@export var nonplaceable_terrain : Array[EnvTerrain] = [preload("res://Resources/EnvTerrain/TerrainTiles/Water.tres")]
@export var water_platforms : Array[String] = ["turtle"]

func test(board : BoardMatrixData, tile_pos : Vector2i, source : CardInstanceData) -> bool:
	var current_tile_terrain : EnvTerrain = board.get_tile(tile_pos).get_terrain()
	if current_tile_terrain in nonplaceable_terrain:
		return is_platform(board, tile_pos)
	return true

func is_platform(board : BoardMatrixData, tile_pos : Vector2i) -> bool:
	var placeable_arr = board.get_tile(tile_pos).placeable_arr
		
	for pn in placeable_arr:
		if pn and pn.data.id_name in water_platforms:
			return true
	return false
