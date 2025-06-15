extends Resource
class_name CardData

@export_category("Basic Properties")
@export var id_name : String
@export var display_name : String
@export var card_sprite : Texture2D

# Description to show the user whenever they select or hover over the card?
@export_multiline var desc : String
@export_multiline var flavor : String

@export_category("Tags and Combos")
enum CATEGORY { 
	Sabotage, Economy, Religion, 
	Infrastructure, Farming, Science, 
	Culture, Nature, Industry, Power }

# influences some auras and card back colour
@export var category: CATEGORY
@export var tags : Array[String]
@export var is_aura : bool = false
# hidden cards are not shown in compendium
@export var hidden : bool = false

func get_id() -> String:
	return id_name
