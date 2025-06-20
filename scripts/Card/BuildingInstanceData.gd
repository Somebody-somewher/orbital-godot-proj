extends CardInstanceData
class_name BuildingInstanceData

var data : BuildingData

var foil : bool

func _init(data : BuildingData, card_attr : int):
	super._init(data)
	self.data = data
	if card_attr > 90:
		foil = true

func get_data() -> BuildingData:
	return data	

		
