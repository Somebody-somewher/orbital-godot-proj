extends Node
class_name CardLoader
# https://github.com/derkork/godot-resource-groups

@export var building_grp : ResourceGroup
@export var event_grp : ResourceGroup
@export var sets_grp : ResourceGroup

static var buildings_dict = {}


static var cardset_types : Array[CardSetData] = []
static var buildings : Array[BuildingData] = []
#static var events : Array[Event] = []


#for constructors
static var building_card_scene: PackedScene = preload("res://scenes/Card/building_card.tscn")
static var aura_card_scene: PackedScene = preload("res://scenes/Card/aura_card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load all buildings data 
	building_grp.load_all_into(buildings)
	
	for b in buildings:
		if b:
			buildings_dict.get_or_add(b.id_name, b)
	
	sets_grp.load_all_into(cardset_types)

static func get_building_data(id : String) -> BuildingData:
	return buildings_dict.get(id).duplicate(true)

static func get_display_name(id : String) -> String:
	print(buildings_dict)
	return buildings_dict.get(id).display_name

static func get_texture(id : String) -> Texture2D:
	return buildings_dict.get(id).card_sprite

static func get_random_set(n : int) -> Array[CardSetData]:
	var size = cardset_types.size()
	var arr : Array[CardSetData] = []
	for i in range(n):
		arr.append(cardset_types[randi() % size])
	return arr
