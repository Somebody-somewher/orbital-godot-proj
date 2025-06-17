extends Node
# https://github.com/derkork/godot-resource-groups

@export var event_grp : ResourceGroup

# BuildingData
@export var building_grp : ResourceGroup
var buildings : Array[BuildingData] = []
var buildings_dict = {}


#TODO: Would like to deprecate this if thatsok. CardPackManagerBase handles this job now
# CardSetData
#@export var sets_grp : ResourceGroup
#var cardset_types : Array[CardSetData] = []
#var cardset_dict = {}
#static var events : Array[Event] = []

var card_set_manager

#for constructors
var building_card_scene: PackedScene = preload("res://scenes/Card/building_card.tscn")
var aura_card_scene: PackedScene = preload("res://scenes/Card/aura_card.tscn")

var player_resources : Dictionary[int, PlayerCardResources]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load all buildings data 
	building_grp.load_all_into(buildings)
	
	for b in buildings:
		if b:
			buildings_dict.get_or_add(b.get_id(), b)
	
	#TODO: Would like to deprecate this if thatsok. CardPackManagerBase handles this job now
	#sets_grp.load_all_into(cardset_types)
	#
	#for cs in cardset_types:
		#if cs:
			#cardset_dict.get_or_add(cs.get_id(), cs)

func get_building_data(id : String) -> BuildingData:
	return buildings_dict.get(id).duplicate(true)

func get_card_data(id : String) -> CardData:
	return buildings_dict.get(id)

func get_display_name(id : String) -> String:
	return buildings_dict.get(id).display_name

func get_texture(id : String) -> Texture2D:
	return buildings_dict.get(id).card_sprite

#TODO: Would like to deprecate this if thatsok. CardPackManagerBase handles this job now
#func get_random_set(n : int) -> Array[CardSetData]:
	#var size = cardset_types.size()
	#var arr : Array[CardSetData] = []
	#for i in range(n):
		#arr.append(cardset_types[randi() % size])
	#return arr
