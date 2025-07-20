#extends BoardEvent
#class_name ClearTileEvent
#
#
#func preview(board : BoardMatrixData, previewer : Callable, tile_pos : Vector2i) -> void:
	#pass
#
## destroys the tile, can be chained with place event to simulate a sabotage landing and squishing a tile
#func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : Node2D) -> void:
	#board.get_tile(tile_pos).clear_tile()
