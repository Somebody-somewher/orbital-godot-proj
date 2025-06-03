extends Node
class_name CardLoader
# https://github.com/derkork/godot-resource-groups

@export var building_grp : ResourceGroup
@export var event_grp : ResourceGroup


static var buildings_dict = {}


static var cardset_types : Array[CardSet] = []
static var buildings : Array[BuildingData] = []
static var events : Array[Event] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load all buildings data 
	building_grp.load_all_into(buildings)
	for b in buildings:
		if b:
			buildings_dict.get_or_add(b.id_name, b)

static func get_building_data(id : String) -> BuildingData:
	#print(buildings_dict)
	return buildings_dict.get(id)

static func get_display_name(id : String) -> String:
	return buildings_dict.get(id).display_name
