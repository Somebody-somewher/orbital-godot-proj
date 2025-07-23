extends PlaceableInstanceData
class_name BuildingInstanceData

var num_rounds_spent_placed := 0

var score : int

var foil : bool

func _init(instance_id : String, carddata : BuildingData, card_attr : int):
	super._init(instance_id, carddata, card_attr)
	if card_attr > 90:
		foil = true
	score = carddata.base_score
	

func get_data() -> BuildingData:
	return data

func serialize() -> Dictionary:
	var output = super.serialize()
	output['foil'] = foil
	output['rounds'] = num_rounds_spent_placed
	output['score'] = score
	return output

static func deserialize(serialized_obj : Dictionary, carddata : CardData) -> BuildingInstanceData:
	var instance := BuildingInstanceData.new("", carddata, 0)
	instance.resync(serialized_obj)
	instance.data = (carddata as BuildingData)
	return instance

func resync(serialized_obj : Dictionary) -> void:
	super.resync(serialized_obj)
	foil = serialized_obj['foil']
	num_rounds_spent_placed = serialized_obj['rounds']
	tile_pos = serialized_obj['tilepos']
	score = serialized_obj['score']
	
