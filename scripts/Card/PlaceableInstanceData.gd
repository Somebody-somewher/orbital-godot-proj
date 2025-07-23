extends PlayableInstanceData
class_name PlaceableInstanceData

var destroy_func : Callable
var tile_pos := Vector2i(-1,-1)

func _init(instance_id : String, carddata : PlaceableData, card_attr : int):
	super._init(instance_id, carddata, card_attr)

func get_data() -> PlaceableData:
	return data	

func serialize() -> Dictionary:
	var output = super.serialize()
	output['data_id'] = data.get_id()
	output['tilepos'] = tile_pos
	return output

func resync(serialized_obj : Dictionary) -> void:
	super.resync(serialized_obj)
	tile_pos = serialized_obj['tilepos']

static func deserialize(serialized_obj : Dictionary, carddata : CardData) -> PlaceableInstanceData:
	var instance := PlaceableInstanceData.new("", null, 0)
	instance.resync(serialized_obj)
	instance.data = (carddata as PlaceableData)
	return instance	

func client_on_place(on_destroy : Callable) -> void:
	destroy_func = on_destroy

func destroy() -> void:
	if destroy_func:
		destroy_func.call()
