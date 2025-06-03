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
var placeable_arr : Array[PlaceableNode]

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


func redraw() -> void:
	for placeable in placeable_arr:
		placeable.global_position = _global_board_pos
