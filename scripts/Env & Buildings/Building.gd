extends PlaceableObject
class_name Building

# building events
var score_effect : Resource = preload("res://scripts/Events/ScoreScripts/standard_score.gd").new()
var place_effect : Array[Resource] = [score_effect]
var destroy_effect : Array[Resource]
var round_adv_effect : Array[Resource]
var timed_effect: Array[Resource]

# allows for scoring can move once scoring system is finalized
@onready
var statmanager_ref = $"../../StatsManager"

#for constructor
static var building_scene: PackedScene = load("res://scenes/Building.tscn")

static var database_ref = preload("res://scripts/Card/card_database.gd")

# resource loading, can remove once script laoder is up and running
static var stack_pred = preload("res://scripts/PlaceConditions/placeable_if_stackable.gd").new()

func _ready() -> void:
	# again, can remove this when scoring manager is finalized
	statmanager_ref.connect_event_signals(score_effect)

# factory constructor
static func new_building(building_name : String) -> Building:
	var ret_building : Building = building_scene.instantiate()
	ret_building.get_node("EntityImage").texture = SpriteSheetLoader.get_sprite(building_name)
	ret_building.id_name = building_name
	# TODO: eventually use database to query name and set variables
	ret_building.place_conditions = [stack_pred]
	return ret_building

# triggers all events in any array, can add timing here
func trigger_event_arr(arr : Array[Resource], board_matrix, tile_pos : Vector2i):
	for event in arr:
		event.trigger(self.id_name, board_matrix, tile_pos)
