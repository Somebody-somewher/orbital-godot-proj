extends BoardEvent
class_name DestroySelfEvent


func preview(board : Board, previewer : Callable, tile_pos : Vector2i) -> void:
	pass

# destroys the building, #TODO building should trigger its own OnDestroyEvents
func trigger(board : Board, tile_pos : Vector2i, caller : Node2D) -> void:
	caller as PlaceableNode
	await board.board_matrix.get_tile(tile_pos).delete_from_tile(caller)
	caller.destroy()
	
