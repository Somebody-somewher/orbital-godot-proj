extends BoardEvent
class_name MoveTileEvent

@export var rescore_when_move : bool = false

## for springs, moves all buildings on a tile to a new location
func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	var available = []
	var buildings : Array[BuildingInstanceData] = board.get_tile(tile_pos).get_buildings_on_tile()
	
	for building_data in buildings:
		if caller == building_data:
			# dont move yourself
			pass
		for dir in aoe.aoe_tile_positions:
			var new_spot = tile_pos + dir
			if board._tile_on_board(new_spot) and CardLoader.event_manager.check_conditions(
				building_data, "is_placeable", [new_spot]):
					available.append(new_spot)
		
		if !available.is_empty():
			var new_spot = available.pick_random()
			
			#print("MOVE ", tile_pos , " " ,new_spot)
			Signalbus.remove_placeable.emit(building_data.get_id(), building_data.get_owner_uuid(), false)
			Signalbus.place_placeable.emit(building_data, new_spot, building_data.get_owner_uuid(), rescore_when_move)
		
