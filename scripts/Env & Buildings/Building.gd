extends PlaceableNode
class_name Building

# allows for scoring can move once scoring system is finalized
static var building_scene: PackedScene = load("res://scenes/Building.tscn")

# factory constructor
static func new_building(building_name : String) -> Building:
	var ret_building : Building = building_scene.instantiate()
	ret_building.data = CardLoader.get_building_data(building_name)
	ret_building.get_node("EntityImage").texture = ret_building.data.building_sprite
	ret_building.data.place_effects.append(ret_building.data.preview_event)
	return ret_building

static func new_building_frm_data(data : BuildingData) -> Building:
	var ret_building : Building = building_scene.instantiate()
	ret_building.data = data
	ret_building.get_node("EntityImage").texture = ret_building.data.building_sprite
	ret_building.data.place_effects.append(ret_building.data.preview_event)
	ret_building.z_index = 1
	return ret_building
