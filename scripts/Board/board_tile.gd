extends Object
class_name BoardTile

# for hover effect
#var score_display : Label

# See if we want to store it as a Resource or some other data later
var _terrain : EnvTerrain
var _global_board_pos : Vector2

signal display_score(score : int)
signal hide_score(score : int)

# Array in case we have stackable buildings
# Should use it as a sorted array, where we calculate scoring from the base tile upwards
var placeable_arr : Array[Building]

func _init(terrain : EnvTerrain):
	_terrain = terrain

func add_placeable(placed_thing : PlaceableNode):
	placeable_arr.push_back(placed_thing)
	placeable_arr.sort_custom(custom_placeable_sort);

func custom_placeable_sort(a : PlaceableNode, b : PlaceableNode):
	if a.layer > b.layer:
		return true;
	return false

func change_terrain(terrain : EnvTerrain):
	_terrain = terrain

# for deleting buildings from tile
func delete_from_tile(placed_thing : PlaceableNode) -> void:
	if placed_thing in placeable_arr:
		placeable_arr.erase(placed_thing)
		placed_thing.free()

func clear_tile() -> void:
	for placeable in placeable_arr:
		placeable.dissolving = true
	placeable_arr = []

# cosmetic functions, score_display is guarenteed to be not null
#func display_score(score : int) :
	#if score != 0:
		#score_display.text = str(score)
		#score_display.global_position = _global_board_pos - score_display.size/2 + Vector2(0,-50)
		#score_display.visible = true

#func off_score_display() -> void:
	#score_display.visible = false

func redraw() -> void:
	for placeable in placeable_arr:
		placeable.global_position = _global_board_pos
