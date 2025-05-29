extends PlaceableNode
class_name Building

# allows for scoring can move once scoring system is finalized
static var building_scene: PackedScene = load("res://scenes/Building.tscn")

var dissolving = false
var dissolve_value = 1

func _ready() -> void:
	pass

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
