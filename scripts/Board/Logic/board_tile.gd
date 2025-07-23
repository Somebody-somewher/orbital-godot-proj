extends Object
class_name BoardTile

# for hover effect
#var score_display : Label
const max_layers : int = 4

# See if we want to store it as a Resource or some other data later
var _terrain : EnvTerrain
var _global_board_pos : Vector2

signal display_score(score : int)
signal hide_score(score : int)

# Array in case we have stackable buildings
# Should use it as a sorted array, where we calculate scoring from the base tile upwards
var placeable_arr : Array[BuildingInstanceData]

func _init(terrain : EnvTerrain):
	_terrain = terrain
	placeable_arr.resize(5)
	placeable_arr.fill(null)

func add_placeable(placed_thing : BuildingInstanceData):
	assert(placeable_arr[placed_thing.get_data().layer] == null)
	placeable_arr[placed_thing.get_data().layer] = placed_thing
	#placeable_arr.sort_custom(custom_placeable_sort);

func custom_placeable_sort(a : BuildingInstanceData, b : BuildingInstanceData):
	if a.get_data().layer > b.get_data().layer:
		return true;
	return false

func change_terrain(terrain : EnvTerrain):
	_terrain = terrain

func get_terrain() -> EnvTerrain:
	return _terrain

func check_if_layer_occupied(layer_index : int) -> bool:
	if placeable_arr[layer_index]:
		return true
	return false

func get_buildings_on_tile() -> Array[BuildingInstanceData]:
	var arr : Array[BuildingInstanceData] = []
	for o in placeable_arr:
		if o:
			arr.append(o)
	return arr

func get_building_on_tile(building_id : String) -> BuildingInstanceData:
	for o in placeable_arr:
		if o and o.get_id() == building_id:
			return o
	return null

func foreach_building_on_tile(c : Callable) -> void:
	for o in placeable_arr:
		if o:
			c.call(o)
# for deleting buildings from tile
func delete_from_tile(placeable_id : String) -> void:

	for index in range(len(placeable_arr)):
		if placeable_arr[index] and placeable_arr[index].get_id() == placeable_id:
			placeable_arr[index].destroy()
			placeable_arr[index] = null

func clear_tile(on_destroy_trigger : Callable) -> void:
	for index in len(placeable_arr):
		if placeable_arr[index] != null:
			on_destroy_trigger.call(placeable_arr[index])
			placeable_arr[index].destroy()
			placeable_arr[index] = null
	


#func redraw() -> void:
	#for placeable in placeable_arr:
		#placeable.global_position = _global_board_pos
