extends Resource
class_name CardSetData

# Pair of BuildingData-Int (number of cards containing this building)
@export var set_name : String

# Technically could be CardData instead of Strings
@export var cards : Dictionary[String, int]
@export var is_multiplayer : bool 

# range from 0 - 3 (common, uncommon, rare, epic)
@export var rarity : int = 0
@export var aquatic : bool

func get_id() -> String:
	return set_name
