extends BoardEvent
class_name MoveEvent

@export var directions : Array[Vector2i] = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
## how many points it earns if it moves
@export var move_bonus : int = 0
@export var rescore_when_move : bool = false

## simulates move to a possible adj tile. If not placeable anywhere then it stays still
func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	var available = []
	for dir in directions:
		var new_spot = tile_pos + dir
		if board._tile_on_board(new_spot) and CardLoader.event_manager.check_conditions(
			caller, "is_placeable", [new_spot]):
				available.append(new_spot)

	if !available.is_empty():
		var new_spot = available.pick_random()
		Signalbus.remove_placeable.emit(caller.get_id(), caller.get_owner_uuid())
		Signalbus.place_placeable.emit(caller, new_spot, caller.get_owner_uuid(), rescore_when_move)
		Signalbus.add_score.emit(move_bonus, caller.get_owner_uuid())
	
