extends ProcGenPostBase
class_name ProcGenPostProabilitySwitch

@export var conversion_list : Dictionary[String, String]
@export var terrain : String
# Probability chance out of 100
@export var probability : Dictionary[String, int]

func process_per_tile(tile_contents : Array) -> void:
	var item
	for i in range(1, len(tile_contents)):
		item = tile_contents[i]
		if tile_contents[0] == terrain && item in conversion_list:
			if probability[item] > randi_range(0, 100):
				tile_contents[i] = conversion_list[item]
	
