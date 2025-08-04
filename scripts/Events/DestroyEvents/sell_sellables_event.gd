extends StandardScoreEffect
class_name TraderEvent

@export var tag_to_sell : String
@export var chance : float = 0.5

@export var trigger_scoring : bool = false

# destroys the building, #TODO building should trigger its own OnDestroyEvents
func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	if trigger_scoring:
		super.trigger(board, tile_pos, caller)
	var tile_pos_data = aoe.get_scored_tiles(tile_pos)
	
	var arr : Array[BuildingInstanceData]
	#for tiledata in tile_pos_data[1]:
	for i in range(tile_pos_data[1].size()):
		arr = tile_pos_data[1][i].get_buildings_on_tile()
		for building in arr:
			if building.get_data().has_tag(tag_to_sell):
				Signalbus.remove_placeable.emit(building.get_id(), caller.get_owner_uuid())
				var sell_score = building.get_data().base_score
				if sell_score > 0:
					Signalbus.add_score.emit(sell_score, caller.get_owner_uuid())
					Signalbus.call_point_fx.emit(sell_score, tile_pos_data[0][i], caller.get_owner_uuid(), tile_pos)
	pass

func modifier(tile_data : BoardTile, _cum_score := 0) -> int:
	var score := 0
	for building in tile_data.get_buildings_on_tile():
		if building.get_data().has_tag(tag_to_sell):
			score += building.score #effect_buildings_score.get(building.data.id_name, 0)
	return score
