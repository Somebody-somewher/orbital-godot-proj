extends BoardEvent
class_name DestroySelfEvent


func preview(board : BoardMatrixData, previewer : Callable, tile_pos : Vector2i) -> void:
	pass

# destroys the building, #TODO building should trigger its own OnDestroyEvents
func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : Node2D) -> void:
	caller as PlaceableNode
	board.get_tile(tile_pos).delete_from_tile(caller)
	caller.destroy()
	
