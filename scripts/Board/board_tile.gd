extends Object
class_name BoardTile

var tile_built := false
# for hover effect
var score_display : Label
# for calculating who plays card
var owner_id : int

# TODO:
# Currently we are storing all this data in card_database as an array
# See if we want to store it as a Resource or some other data later
var _terrain : EnvTerrain
var _global_board_pos : Vector2

# Array in case we have stackable buildings
# Should use it as a sorted array, where we calculate scoring from the base tile upwards
var buildings : Array[Building]
# for database query use
var buildings_name_arr : Array[String]

static var database_ref = preload("res://scripts/Card/card_database.gd")


func _init(terrain : EnvTerrain, pos : Vector2):
	_terrain = terrain
	_global_board_pos = pos

func add_building(building : Building):
	buildings.push_back(building)
	buildings.sort_custom(custom_building_sort);
	buildings_name_arr.push_back(building.id_name)

func custom_building_sort(a : Building, b : Building):
	if a.layer > b.layer:
		return true;
	return false

func change_terrain(terrain : EnvTerrain):
	_terrain = terrain

# checks if a new_building can be stacked onto current tile returns success
func stack_if_able(new_building : Building) -> bool :
	var stackable = can_stack(new_building)
	if stackable:
		add_building(new_building)
	return stackable

func can_stack(new_building : Building) -> bool :
	# empty_tile
	if buildings.is_empty():
		return true
	# check if stackable
	var stackable_buildings = database_ref.get_card_stackables_by_id(new_building.id_name)
	for building in buildings:
		if building.id_name in stackable_buildings:
			return true
	return false

#returns nonegative int for how much a building affects this tile
func calculate_score(new_building : Building) -> int :
	return database_ref.get_tile_score(buildings_name_arr, new_building.id_name)
	

# for deleting buildings from tile
func delete_from_tile(building : Building, add_back_to_hand : bool) -> void:
	if building in buildings:
		buildings.erase(building)
		if add_back_to_hand:
			var returned_card = building.swap_to_card() # swap_to_card not implemented
			# TODO: add functionality to add card back to hand
		building.free()

# cosmetic functions, score_display is guarenteed to be not null
func calculate_and_display(new_building : Building) -> void :
	var score = calculate_score(new_building)
	if score != 0 :
		score_display.text = str(score)
		score_display.global_position = _global_board_pos - score_display.size/2 + Vector2(0,-40)
		score_display.visible = true

func off_score_display() -> void :
	score_display.visible = false

func redraw() -> void:
	for building in buildings:
		building.global_position = _global_board_pos
