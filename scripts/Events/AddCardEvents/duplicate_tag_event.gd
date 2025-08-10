extends BoardEvent
class_name DuplicateTagsEvent

@export var tag_to_dupe : String
@export var chance : float = 0.2

# destroys the building, #TODO building should trigger its own OnDestroyEvents
func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	var tile_pos_data = aoe.get_scored_tiles(tile_pos)
	var arr : Array[BuildingInstanceData]
	#for tiledata in tile_pos_data[1]:
	for i in range(tile_pos_data[1].size()):
		arr = tile_pos_data[1][i].get_buildings_on_tile()
		for building in arr:
			var data = building.get_data()
			if data.has_tag(tag_to_dupe) and randf() < chance:
				var instance = CardLoader.create_data_instance(data.get_id(), -1)
				instance.set_owner_uuid(caller.get_owner_uuid())
				var pos = Vector2((tile_pos.x + 0.5) * 113, (tile_pos.y + 0.5) * 113)
				(CardLoader.card_mem as ServerCardMemory).add_card_in_hand(instance, caller.get_owner_uuid(), pos)


func modifier(tile_data : BoardTile, _cum_score := 0) -> int:
	return 0
