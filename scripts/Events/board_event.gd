extends Resource # Pretend this is a Functional Interface
class_name BoardEvent

@export var aoe : AOE

func trigger(tile_pos : Vector2i) -> void:
	pass

func preview(previewer : Callable, tile_pos : Vector2i) -> void:
	pass
