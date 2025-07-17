extends Resource
class_name CardSetData

# Pair of BuildingData-Int (number of cards containing this building)
@export var set_name : String
@export var cards : Dictionary[String, int]

# range from 0 - 3 (common, uncommon, rare, epic)
@export var rarity : int = 0

@export var aquatic : bool
@export var sabotage: bool = false
