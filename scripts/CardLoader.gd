extends Node
class_name CardLoader
# https://github.com/derkork/godot-resource-groups

@export var building_grp : ResourceGroup
@export var cardset_grp : ResourceGroup

static var buildings_dict = {}
static var card_types : Array[Card] = []
static var buildings : Array[BuildingData] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Load all buildings data 
	building_grp.load_all_into(buildings)
	for b in buildings:
		buildings_dict.get_or_add(b.id_name, b) 
	pass # Replace with function body.

static func get_building_data(id : String) -> BuildingData:
	return buildings_dict.get(id)
