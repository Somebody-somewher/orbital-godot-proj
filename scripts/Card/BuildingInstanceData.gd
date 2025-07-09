extends PlaceableInstanceData
class_name BuildingInstanceData

var num_rounds_spent_placed := 0
var tile_pos := Vector2i(-1,-1)

var foil : bool


func _init(instance_id : String, data : BuildingData, card_attr : int):
	super._init(instance_id, data, card_attr)
	if card_attr > 90:
		foil = true

func get_data() -> BuildingData:
	return data	

func serialize() -> Dictionary:
	var output = super.serialize()
	output['foil'] = foil
	output['rounds'] = num_rounds_spent_placed
	output['tilepos'] = tile_pos
	return output

static func deserialize(serialized_obj : Dictionary, data : CardData) -> BuildingInstanceData:
	var instance := BuildingInstanceData.new("", null, 0)
	instance.resync(serialized_obj, data)
	return instance

func resync(serialized_obj : Dictionary, data : CardData) -> void:
	data_instance_id = serialized_obj['instance_id']
	owner_uuid = serialized_obj['owner_uuid']
	self.data = (data as BuildingData)
	foil = serialized_obj['foil']
	num_rounds_spent_placed = serialized_obj['rounds']
	tile_pos = serialized_obj['tilepos']
