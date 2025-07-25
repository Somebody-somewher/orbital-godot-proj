extends BoardEvent
class_name DestroySpecificEvent

@export var targets : Array[String]


func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	var tile_pos_data = aoe.get_scored_tiles(tile_pos)
	
	var arr : Array[BuildingInstanceData]
	for tiledata in tile_pos_data[1]:
		arr = tiledata.get_buildings_on_tile()
		for building in arr:
			if building.get_data().get_id() in targets :
				Signalbus.remove_placeable.emit(building.get_id(), caller.get_owner_uuid())
