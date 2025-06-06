extends BoardEvent
class_name CreateCardsEvent

# cards to create in card id, no of cards pairs
@export var cards: Dictionary[String, int]

func preview(board : Board, previewer : Callable, tile_pos : Vector2i) -> void:
	pass

# destroys the building, #TODO building should trigger its own OnDestroyEvents
func trigger(board : Board, tile_pos : Vector2i, caller : Node2D) -> void:
	for key in cards.keys():
		for no in range(cards[key]):
			Signalbus.spawn_card.emit(key, board.get_global_tile_pos(tile_pos))
