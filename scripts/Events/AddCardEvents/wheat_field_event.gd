extends BoardEvent
class_name WheatEvent

@export var id_to_create : String
@export var chance_per_surrounding : float = 0.1

# when a wheat a surrounded by more wheat, each wheat has increased chance to spawn a wheat card
func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	var tile_pos_data = aoe.get_scored_tiles(tile_pos)
	var arr : Array[BuildingInstanceData]
	var cum_chance = 0
	for i in range(tile_pos_data[1].size()):
		arr = tile_pos_data[1][i].get_buildings_on_tile()
		for building in arr:
			if building.get_data().get_id() == id_to_create:
				cum_chance += chance_per_surrounding
	if randf() < cum_chance:
		var instance = CardLoader.create_data_instance(id_to_create, -1)
		instance.set_owner_uuid(caller.get_owner_uuid())
		var pos = Vector2((tile_pos.x + 0.5) * 113, (tile_pos.y + 0.5) * 113)
		(CardLoader.card_mem as ServerCardMemory).add_card_in_hand(instance, caller.get_owner_uuid(), pos)


func modifier(tile_data : BoardTile, _cum_score := 0) -> int:
	return 0
