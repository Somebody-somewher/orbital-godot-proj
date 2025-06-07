extends Resource
class_name CardData

@export_category("Basic Properties")
@export var id_name : String
@export var display_name : String
@export var card_sprite : Texture2D

# Description to show the user whenever they select or hover over the card?
@export_multiline var desc : String

@export_category("Tags and Combos")
enum Category { 
	SABOTAGE, ECONOMY, RELIGION, 
	INFRASTRUCTURE, FARMING, SCIENCE, 
	CULTURE, NATURE, INDUSTRY, POWER }

# influences some auras and card back colour
@export var category: Category
@export var is_aura : bool = false
@export var tags : Array[String]
