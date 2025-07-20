#extends BoardEvent
#class_name ProduceCardsEvent
#
## cards to create in card id, no of cards pairs
#@export var cards: Dictionary[String, int]
#@export var chance : float = 0.5
#
#func preview(board : BoardMatrixData, previewer : Callable, tile_pos : Vector2i) -> void:
	#pass
#
#
#func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : Node2D) -> void:
	#for key in cards.keys():
		#for no in range(cards[key]):
			#Signalbus.emit_signal("spawn_card", key, Vector2i(0,0))
			##board.get_global_tile_pos(tile_pos)
