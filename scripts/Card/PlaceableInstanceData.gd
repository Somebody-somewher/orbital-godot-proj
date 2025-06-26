extends CardInstanceData
class_name PlaceableInstanceData

var data : PlaceableData

func _init(instance_id : String, data : PlaceableData, card_attr : int):
	super._init(instance_id, data)
	self.data = data

func get_data() -> BuildingData:
	return data	

		
