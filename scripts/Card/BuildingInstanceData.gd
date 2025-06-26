extends PlaceableInstanceData
class_name BuildingInstanceData

var foil : bool

func _init(data : BuildingData, card_attr : int):
	super._init(data, card_attr)
	if card_attr > 90:
		foil = true

static func duplicate(data : CardInstanceData) -> BuildingInstanceData:
	assert(data is BuildingInstanceData)
	if data is BuildingInstanceData:
		return BuildingInstanceData.new(data.get_data(), data.card_attr)
	else:
		return null

func get_data() -> BuildingData:
	return data	

		
