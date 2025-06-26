extends PlaceableInstanceData
class_name BuildingInstanceData

var foil : bool

func _init(instance_id : String, data : BuildingData, card_attr : int):
	super._init(instance_id, data, card_attr)
	if card_attr > 90:
		foil = true

func get_data() -> BuildingData:
	return data	

		
