extends CardInstanceData
class_name PlaceableInstanceData

var data : PlaceableData

func _init(data : PlaceableData, card_attr : int):
	super._init(data)
	self.data = data

static func duplicate(data : CardInstanceData) -> PlaceableInstanceData:
	assert(data is PlaceableInstanceData)
	if data is PlaceableInstanceData:
		return PlaceableInstanceData.new(data.get_data(), data.card_attr)
	else:
		return null

func get_data() -> BuildingData:
	return data	

		
