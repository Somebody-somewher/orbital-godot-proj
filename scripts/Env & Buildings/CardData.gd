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
	Infrastructure, Farming, Tech, 
	Culture, Nature, Industry, Power }

# influences some auras and card back colour
@export var category: CATEGORY
@export var tags : Array[String]
@export var is_aura : bool = false
# hidden cards are not shown in compendium
@export var hidden : bool = false

@export var override_default : bool = false

func has_tag(tag_name : String) -> bool:
	return tags.find(tag_name) != -1

func load_default_preset() -> void:
	pass
	
func get_events_as_dict() -> Dictionary[String, Array]:
	return {}

func get_id() -> String:
	return id_name
