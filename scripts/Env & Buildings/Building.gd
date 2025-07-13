extends PlaceableNode
class_name Building

# allows for scoring can move once scoring system is finalized
static var building_scene: PackedScene = load("res://scenes/Building.tscn")

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
	#ret_building.data_instance.place_effects.append(data_inst.get_data().preview_event)
	#ret_building.data_instance.get_data().place_effects.append(data_inst.get_data().preview_event)
	ret_building.z_index = 1
	ret_building.name = data_inst.get_id()
	return ret_building
