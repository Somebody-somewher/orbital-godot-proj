extends Node2D
class_name PlaceableNode
# abstract class handling functions of card object before they are placed

@export var data : PlaceableData

# As defined in card_database
@export var layer : int # for stacking and rendering

# triggers all events in any array, can add timing here
func trigger_event_arr(arr : Array[BoardEvent], board_matrix, tile_pos : Vector2i):
	for event in arr:
		event.trigger(board_matrix, tile_pos)

func trigger_place_effects(board_matrix, tile_pos : Vector2i) -> void:
	for event in data.place_effects:
		event.trigger(board_matrix, tile_pos)

func placeable(board, pos : Vector2i) -> bool:
	return data.placeable(board, pos)
