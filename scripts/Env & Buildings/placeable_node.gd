extends Node2D
class_name PlaceableNode
# abstract class handling functions of card object before they are placed

@export var data : PlaceableData

# As defined in card_database
@export var layer : int # for stacking and rendering

var dissolving = false
var dissolve_value = 1

func _ready() -> void:
	# just so dissolving is only run when needed to save comuptation, can change down the line
	set_process(false)

func _process(delta: float) -> void:
	if dissolving:
		if dissolve_value > 0:
			get_node("EntityImage").material.set_shader_parameter("dissolve_value", dissolve_value)
			dissolve_value -= delta * 1.6
		else:
			get_node("EntityImage").visible = false
			queue_free()
	pass

# triggers all events in any array, can add timing here
func trigger_event_arr(board : BoardMatrixData, arr : Array[BoardEvent], tile_pos : Vector2i):
	for event in arr:
		event.trigger(board, tile_pos, self)

func trigger_place_effects(board : BoardMatrixData, tile_pos : Vector2i) -> void:
	for event in data.place_effects:
		event.trigger(board, tile_pos, self)

func trigger_post_place_effects(board : BoardMatrixData, tile_pos : Vector2i) -> void:
	for event in data.post_place_effects:
		event.trigger(board, tile_pos, self)

func placeable(board : BoardMatrixData, pos : Vector2i) -> bool:
	return data.placeable(board, pos)

func destroy() -> void:
	# TODO trigger destory effects here
	dissolve()
	pass

func dissolve():
	dissolving = true
	set_process(true)
