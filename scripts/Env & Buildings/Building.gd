extends PlaceableNode
class_name Building


@onready var shiny_particles: CPUParticles2D = $"shiny particles"

# allows for scoring can move once scoring system is finalized
static var building_scene: PackedScene = load("res://scenes/Building.tscn")
#static var foil_mat : Material = load("res://shader/Foil/foil_mat.tres")

func toggle_shiny(on : bool):
	shiny_particles.emitting = on
 
# factory constructor
static func new_building(building_name : String) -> Building:
	var ret_building : Building = building_scene.instantiate()
	var data = CardLoader.get_building_data(building_name)
	ret_building.get_node("EntityImage").texture = data.card_sprite
	ret_building.name = building_name
	return ret_building

static func new_building_frm_data(data_inst : BuildingInstanceData) -> Building:
	var ret_building : Building = building_scene.instantiate()
	ret_building.data_instance = data_inst
	ret_building.get_node("EntityImage").texture = data_inst.get_data().card_sprite
	if data_inst.foil:
		ret_building.get_node("shiny particles").emitting = true
	ret_building.z_index = data_inst.get_data().layer
	ret_building.name = data_inst.get_id()
	return ret_building
