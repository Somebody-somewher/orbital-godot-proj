extends Object
class_name BoardTile

var tile_built = false
# TODO:
# Currently we are storing all this data in card_database as an array
# See if we want to store it as a Resource or some other data later
var _terrain : EnvTerrain
var _global_board_pos : Vector2

# Array in case we have stackable buildings
# Should use it as a sorted array, where we calculate scoring from the base tile upwards
var buildings : Array[Building]

func _init(terrain : EnvTerrain, pos : Vector2):
	_terrain = terrain
	_global_board_pos = pos

func add_building(building : Building):
	buildings.push_back(building)
	buildings.sort_custom(custom_building_sort);

func custom_building_sort(a : Building, b : Building):
	if a.layer > b.layer:
		return true;
	return false

func change_terrain(terrain : EnvTerrain):
	_terrain = terrain

# checks if a new_building can be stacked onto current tile returns success
func stack_if_able(new_building : Building) -> bool :
	# empty_tile
	if buildings.is_empty():
		add_building(new_building)
		return true
	# check if stackable
	for building in buildings:
		if building.id_name in new_building.stackable_buildings:
			add_building(new_building)
			return true
	return false

# for deleting buildings from tile
func delete_from_tile(building : Building, add_back_to_hand : bool) -> void:
	if building in buildings:
		buildings.erase(building)
		if add_back_to_hand:
			var returned_card = building.swap_to_card() # swap_to_card not implemented
			# TODO: add functionality to add card back to hand
		building.free()

func redraw() -> void:
	for building in buildings:
		building.global_position = _global_board_pos
