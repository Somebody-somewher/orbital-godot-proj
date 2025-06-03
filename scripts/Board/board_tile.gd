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
var buildings : Array[Building]

func _init(terrain : EnvTerrain):
	_terrain = terrain

func add_building(building : Building):
	buildings.push_back(building)
	buildings.sort_custom(custom_building_sort);

func custom_building_sort(a : Building, b : Building):
	if a.layer > b.layer:
		return true;
	return false

func change_terrain(terrain : EnvTerrain):
	_terrain = terrain

# for deleting buildings from tile
func delete_from_tile(building : Building) -> void:
	if building in buildings:
		buildings.erase(building)
		building.free()

func clear_tile() -> void:
	for building in buildings:
		building.dissolving = true
	buildings = []

# cosmetic functions, score_display is guarenteed to be not null
#func display_score(score : int) :
	#if score != 0:
		#score_display.text = str(score)
		#score_display.global_position = _global_board_pos - score_display.size/2 + Vector2(0,-50)
		#score_display.visible = true

#func off_score_display() -> void:
	#score_display.visible = false

func redraw() -> void:
	for building in buildings:
		building.global_position = _global_board_pos
