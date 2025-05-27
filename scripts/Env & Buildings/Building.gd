extends PlaceableObject
class_name Building

var dissolving := false
var dissolve_value := 1

# building events
var score_effect : ScoreEffect = preload("res://scripts/Events/ScoreScripts/standard_score.gd").new()
var place_effect : Array[BoardEvent] = [score_effect]
var destroy_effect : Array[BoardEvent]
var round_adv_effect : Array[BoardEvent]
var timed_effect: Array[BoardEvent]

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dissolving:
		if dissolve_value > 0:
			get_node("EntityImage").material.set_shader_parameter("DissolveValue", dissolve_value)
			dissolve_value -= delta * 1.6
		else:
			get_node("EntityImage").visible = false
			queue_free()
	pass

# factory constructor
static func new_building(building_name : String) -> Building:
	var ret_building : Building = building_scene.instantiate()
	ret_building.get_node("EntityImage").texture = load("res://assets/entity_sprites/"+ building_name + ".png")
	ret_building.id_name = building_name
	# TODO: eventually use database to query name and set variables
	ret_building.place_conditions = [stack_pred]
	return ret_building

# triggers all events in any array, can add timing here
func trigger_event_arr(arr : Array[BoardEvent], board_matrix, tile_pos : Vector2i):
	for event in arr:
		event.trigger(self.id_name, board_matrix, tile_pos)

func dissolve_build() -> void:
	dissolving = true
