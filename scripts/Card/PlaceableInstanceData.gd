extends PlayableInstanceData
class_name PlaceableInstanceData

var place_conditions : Array[Condition] 
var place_conditions_dict : Dictionary[String, Condition]

var preview_event : BoardEvent

func _init(instance_id : String, data : PlaceableData, card_attr : int):
	super._init(instance_id, data, card_attr)
	preview_event = data.preview_event
	place_conditions = data.place_conditions

func preview(matrix : BoardMatrixData, tile_previewer : Callable, tilepos : Vector2i) -> void:
	preview_event.preview(matrix, tile_previewer, tilepos)
	pass

func is_placeable() -> bool:
	for condition in place_conditions:
		if !condition.test():
			return false
	return true

func get_data() -> PlaceableData:
	return data	

func serialize() -> Dictionary:
	var output = super.serialize()
	output['data_id'] = data.get_id()
	return output

func resync(serialized_obj : Dictionary) -> void:
	super.resync(serialized_obj)

static func deserialize(serialized_obj : Dictionary, data : CardData) -> PlaceableInstanceData:
	var instance := PlaceableInstanceData.new("", null, 0)
	instance.resync(serialized_obj)
	instance.data = (data as PlaceableData)

	return instance	

 #CardLoader.get_card_data(serialized_obj['data_id'])

#func preview(board : BoardMatrixData, previewer : Callable, tile_pos : Vector2i) -> void:
	#return preview_event.preview(board, previewer, tile_pos)
	
	
#func placeable(board : BoardMatrixData, pos : Vector2i) -> bool:
	#for condition in place_conditions:
		#if !condition.test(board, pos):
			#return false
	#return true
