extends Node
class_name CardLoader
# https://github.com/derkork/godot-resource-groups

@export var building_grp : ResourceGroup
@export var aura_grp : ResourceGroup
@export var event_grp : ResourceGroup
@export var sets_grp : ResourceGroup

static var card_dict : Dictionary[String, CardData] = {}


static var cardset_types : Array[CardSetData] = []
static var buildings : Array[BuildingData] = []
static var auras : Array[AuraCardData] = []
#static var events : Array[Event] = []


#for constructors
static var placeable_card_scene: PackedScene = preload("res://scenes/Card/placeable_card.tscn")
static var aura_card_scene: PackedScene = preload("res://scenes/Card/aura_card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load all buildings data 
	building_grp.load_all_into(buildings)
	aura_grp.load_all_into(auras)
	
	for aura_data in auras:
		if aura_data:
			card_dict.get_or_add(aura_data.id_name, aura_data)
	
	for b_data in buildings:
		if b_data:
			card_dict.get_or_add(b_data.id_name, b_data)

	sets_grp.load_all_into(cardset_types)

static func new_card(card_name : String) -> Card:
	var data = CardLoader.get_building_data(card_name)
	var return_card
	if data is BuildingData:
		return_card = CardLoaderr.placeable_card_scene.instantiate() as PlaceableCard
	elif data is AuraCardData:
		return_card = CardLoaderr.aura_card_scene.instantiate() as AuraCard
		
	var card_image_path = str("res://assets/card_sprites/blank_card.png")
	return_card.get_node("CardImage").texture = load(card_image_path)
	return_card.get_node("EntityImage").texture = data.card_sprite
	return_card.get_node("Texts/CardName").text = data.display_name
	return_card.id_name = card_name
	return return_card

static func get_building_data(id : String) -> CardData:
	return card_dict.get(id).duplicate(true)

static func get_card_data(id : String) -> CardData:
	return card_dict.get(id)

static func get_display_name(id : String) -> String:
	return card_dict.get(id).display_name

static func get_texture(id : String) -> Texture2D:
	return card_dict.get(id).card_sprite

static func get_random_set(n : int) -> Array[CardSetData]:
	var size = cardset_types.size()
	var arr : Array[CardSetData] = []
	for i in range(n):
		arr.append(cardset_types[randi() % size])
	return arr
