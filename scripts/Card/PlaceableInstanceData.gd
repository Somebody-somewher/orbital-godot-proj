extends CardInstanceData
class_name PlaceableInstanceData

var data : PlaceableData



func _init(data : PlaceableData, card_attr : int):
	super._init(data)
	self.data = data

func get_data() -> BuildingData:
	return data	

		
