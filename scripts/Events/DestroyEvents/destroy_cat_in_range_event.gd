extends BoardEvent
class_name DestroyCategoryEvent

@export var category : CardData.CATEGORY
@export var tags : String
@export var chance : float = 0.5

func preview(board : BoardMatrixData, previewer : Callable, tile_pos : Vector2i) -> void:
	pass

func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : Node2D) -> void:
	#chance to destroy items with the cat or tags in range, use for weapons to destroy sabotages
	pass
