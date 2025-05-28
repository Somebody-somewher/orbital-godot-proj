extends Resource # Pretend this is a Functional Interface
class_name BoardEvent

@export var aoe : AOE

func trigger(board_matrix, tile_pos : Vector2i) -> void:
	pass

func get_preview(board_matrix, tile_pos : Vector2i) -> Array[Vector2i]:
	return []
