extends Resource
class_name CardSetData

# Pair of BuildingData-Int (number of cards containing this building)
@export var set_name : String

# Technically could be CardData instead of Strings
@export var cards : Dictionary[String, int]

@export_category("Tags and Combos")
enum CATEGORY { 
	Sabotage, Economy, Religion, 
	Infrastructure, Farming, Tech, 
	Culture, Nature, Industry, Power }

# influences some auras and card back colour
@export var category: CATEGORY
# range from 0 - 3 (common, uncommon, rare, epic)
@export var rarity : int = 0
@export var aquatic : bool
@export var sabotage : bool
@export var is_singleplayer : bool 

func get_id() -> String:
	return set_name
