extends Resource
class_name CardSetData

# Pair of BuildingData-Int (number of cards containing this building)
@export var set_name : String
@export var cards : Dictionary[String, int]
