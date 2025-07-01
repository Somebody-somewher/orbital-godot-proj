extends BoardEvent
class_name TraderEvent

@export var sell_aoe : AOE
@export var tag_to_sell : String
@export var chance : float = 0.5

func preview(board : BoardMatrixData, previewer : Callable, tile_pos : Vector2i) -> void:
	pass

# destroys the building, #TODO building should trigger its own OnDestroyEvents
func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : Node2D) -> void:
	#chance to remove items with the tag to sell for base score
	pass
