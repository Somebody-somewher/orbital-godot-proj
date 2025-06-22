extends PlaceableInstanceData
class_name BuildingInstanceData

var foil : bool

func _init(data : BuildingData, card_attr : int):
	super._init(data, card_attr)
	if card_attr > 90:
		foil = true

func get_data() -> BuildingData:
	return data	

		
