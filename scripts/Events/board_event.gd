extends Resource # Pretend this is a Functional Interface
class_name BoardEvent

@export var aoe : AOE

func trigger(board_matrix, tile_pos : Vector2i) -> void:
	pass

func get_preview(board, tile_pos : Vector2i) -> Array[Vector2i]:
	var arr : Array[Vector2i]
	arr.assign(aoe.get_scored_tiles(board, tile_pos)[0])
	return arr
