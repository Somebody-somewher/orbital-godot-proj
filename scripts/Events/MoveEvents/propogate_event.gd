extends BoardEvent
class_name PropogateEvent

@export var directions : Array[Vector2i] = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
@export var chance : float = 0.5
## how many points it earns if it moves

## simulates spreading to a possible adj tile. If not placeable anywhere then nothing happens
func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	var available = []
	if randf() > chance:
		return
	
	for dir in directions:
		var new_spot = tile_pos + dir
		if board._tile_on_board(new_spot) and CardLoader.event_manager.check_conditions(
			caller, "is_placeable", [new_spot]):
				available.append(new_spot)
	
	if !available.is_empty():
		var new_spot = available.pick_random()
		Signalbus.place_placeable.emit(caller, new_spot, caller.get_owner_uuid(), true)
