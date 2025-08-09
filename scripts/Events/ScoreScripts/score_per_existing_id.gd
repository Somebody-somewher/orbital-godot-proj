extends StandardScoreEffect
class_name PassiveIDConditionalScoreEffect

@export var id_to_count : Array[String]
@export var points : int = 1
@export var chance : float = 0.5

##generate x score for each building with tags in aoe
func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	var tile_pos_data = aoe.get_scored_tiles(tile_pos)
	
	var arr : Array[BuildingInstanceData]
	#for tiledata in tile_pos_data[1]:
	for i in range(tile_pos_data[1].size()):
		arr = tile_pos_data[1][i].get_buildings_on_tile()
		for building in arr:
			if building.get_data().id_name in id_to_count and randf() < chance:
				Signalbus.add_score.emit(points, caller.get_owner_uuid())
				Signalbus.call_point_fx.emit(points, tile_pos_data[0][i], caller.get_owner_uuid(), tile_pos)

func modifier(tile_data : BoardTile, _cum_score := 0) -> int:
	var score := 0
	for building in tile_data.get_buildings_on_tile():
		if building.get_data().id_name in id_to_count:
			score += building.score #effect_buildings_score.get(building.data.id_name, 0)
	return score
