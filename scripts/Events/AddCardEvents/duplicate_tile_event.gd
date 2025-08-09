extends BoardEvent
class_name DuplicateTilesEvent

func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	var tile_pos_data = aoe.get_scored_tiles(tile_pos)
	
	var pos = Vector2((tile_pos.x + 0.5) * 113, (tile_pos.y + 0.5) * 113)
	var server_mem = CardLoader.card_mem as ServerCardMemory
	var arr : Array[BuildingInstanceData]
	for tiledata in tile_pos_data[1]:
		arr = tiledata.get_buildings_on_tile()
		for building in arr:
			var instance = CardLoader.create_data_instance(building.get_data().get_id(), -1)
			instance.set_owner_uuid(caller.get_owner_uuid())
			server_mem.add_card_in_hand(instance, caller.get_owner_uuid(), pos)
