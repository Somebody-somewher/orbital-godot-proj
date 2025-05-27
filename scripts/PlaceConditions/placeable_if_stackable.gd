extends PlaceCondition
class_name PlaceIfStackable

func can_place(id_name : String, board_matrix, tile_pos : Vector2i) -> bool:
	var target_tile : BoardTile = board_matrix[tile_pos.x][tile_pos.y]
	if target_tile.buildings.is_empty():
		return true
		
	var stackable_buildings = database_ref.get_card_stackables_by_id(id_name)
	for building in target_tile.buildings:
		if building.id_name in stackable_buildings:
			return true
	return false
