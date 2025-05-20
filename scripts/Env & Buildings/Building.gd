extends Node2D
class_name Building

# in case we want buildings that can be placed ontop of other buildings
# dict contains which buildings this building can be stacked onto
@export var stackable_buildings : Dictionary = {}

# As defined in card_database
@export var id_name : String
@export var AOE : String
@export var layer : int # for stacking and rendering

# A dictionary of pairings (which are also dicts) describing how surrounding buildings
# in the AOE will contribute to scoring for this building
@export var AOE_scorers : Dictionary

# A timer that counts down to events
# maybe a building that tranforms after some time or a building that decays
# -1 for no changes, TODO: function that is called when timer == 0
@export var timer : int = -1

# If buildings can be upgraded or "matured", the resultant building is stored and loaded
# Fun idea, maybe chaining transformations
@export var transformed_building : Building = null

#for constructor
static var building_scene: PackedScene = load("res://scenes/Building.tscn")

static var database_ref = preload("res://scripts/Card/card_database.gd")

func _ready() -> void:
	pass

#constructor
static func new_building(name : String) -> Building:
	var new_building = building_scene.instantiate()
	var entity_image_path = str("res://sprites/entity_sprites/" + name + ".png")
	print(entity_image_path)
	new_building.get_node("EntityImage").texture = load(entity_image_path)
	# TODO: eventually use database to query name and set variables
	return new_building

# for recalling building bakc into player hand
# freeing done by caller
func swap_to_card() -> Card:
	self.get_node("Area2D/CollisionShape2D").disabled = true
	self.visible = false
	var new_card = Card.new_card(id_name)
	new_card.position = self.position
	return new_card
