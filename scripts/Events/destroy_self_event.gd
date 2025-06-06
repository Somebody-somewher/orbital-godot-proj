extends BoardEvent
class_name DestroySelfEvent


func preview(board : Board, previewer : Callable, tile_pos : Vector2i) -> void:
	pass

# destroys the building, #TODO building should trigger its own OnDestroyEvents
func trigger(_board : Board, _tile_pos : Vector2i, caller : Object) -> void:
	pass
