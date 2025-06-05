extends ProcGenPostProcessBuildingInterface
class_name ProcGenPostProabilitySwitch

@export var conversion_list : Dictionary[BuildingData, Array]
@export var terrain : EnvTerrain
# Probability chance out of 100
@export var probability : Dictionary[BuildingData, int]
var _terrain_matrix : Array

func process(building_iterator : ProcGenBoardIterator, terrain_iterator : ProcGenBoardIterator) -> void:
	_terrain_matrix = terrain_iterator.retrieve_matrix()
	for bd in conversion_list.keys():
		building_iterator.foreach_ele(bd, convert)
	

func convert(b : BuildingData, pos : Vector2i) -> void:
	var choices
	if _terrain_matrix[pos.x][pos.y] == terrain:
		if randi_range(0,100) < probability.get(b, 101):
			choices = conversion_list.get(b)	
			conversion_list.get(choices[randi_range(0, len(choices-1))])
	
