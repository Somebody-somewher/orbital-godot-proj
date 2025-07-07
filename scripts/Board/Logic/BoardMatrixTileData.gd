extends Object
class_name BoardMatrixTileData

# for hover effect
#var score_display : Label

const num_placeable_layers := 4

# See if we want to store it as a Resource or some other data later
var _terrain : EnvTerrain
var _global_board_pos : Vector2

signal display_score(score : int)
signal hide_score(score : int)

# Array for stackable buildings
var building_arr : Array[BuildingInstanceData]

func _init(terrain : EnvTerrain):
	_terrain = terrain
	building_arr.resize(num_placeable_layers)

func check_layer_occupied(building_instance : BuildingInstanceData) -> BuildingInstanceData:
	return building_arr[building_instance.get_data().layer]	 

func add_placeable(placed_thing : PlaceableNode):
	building_arr.push_back(placed_thing)
	building_arr.sort_custom(custom_placeable_sort);

func custom_placeable_sort(a : PlaceableNode, b : PlaceableNode):
	if a.layer > b.layer:
		return true;
	return false

func change_terrain(terrain : EnvTerrain):
	_terrain = terrain

# for deleting buildings from tile
func delete_from_tile(building_instance_id : String) -> bool:
	for instance in building_arr:
		if instance and instance.get_id() == building_instance_id:
			building_arr.erase(instance)
			return true
	return false
			
#func clear_tile() -> void:
	#for building in building_arr:
		#building.
	#building_arr.clear()
