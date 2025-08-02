extends BoardEvent 
class_name ChangeTerrainEvent

@export var terrain : EnvTerrain

# caller cn be a card that plays animation, or a building that needs moifying
func trigger(_board : BoardMatrixData, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	var tile_pos_data = aoe.get_scored_tiles(tile_pos)
	
	for i in range(len(tile_pos_data[0])):
		if tile_pos_data[1][i].get_terrain().get_id() != terrain.get_id():
			Signalbus.change_terrain.emit(terrain.get_id(), caller.get_owner_uuid(), tile_pos_data[0][i])
	pass

func preview(_board : BoardMatrixData, previewer : Callable, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	var tile_pos_data : = aoe.get_scored_tiles(tile_pos)
	var tile_pos_arr : Array[Vector2i]
	var scores : Array[int]
	scores.resize(len(tile_pos_data[0]))
	
	for i in range(len(tile_pos_data[0])):
		tile_pos_arr.append(tile_pos_data[0][i])
	previewer.call(tile_pos_arr, scores)
	pass
