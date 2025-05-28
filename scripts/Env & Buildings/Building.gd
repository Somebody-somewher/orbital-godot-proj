extends PlaceableNode
class_name Building

# allows for scoring can move once scoring system is finalized
@onready
var statmanager_ref = $"../../StatsManager"

#for constructor
static var building_scene: PackedScene = load("res://scenes/Building.tscn")

static var database_ref = preload("res://scripts/Card/card_database.gd")


func _ready() -> void:
	# TODO: again, can remove this when scoring manager is finalized
	# Scoring function may also not be the preview function. Let data do this?
	statmanager_ref.connect_event_signals(data.preview_event)

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
	ret_building.data = CardLoader.get_building_data(building_name)
	ret_building.get_node("EntityImage").texture = ret_building.data.building_sprite
	return ret_building
