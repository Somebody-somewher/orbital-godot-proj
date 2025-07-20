extends CardInstanceData
class_name PlayableInstanceData

var rounds_in_hand : int

var data : PlayableCardData

func _init(instance_id : String, carddata : PlayableCardData, _card_attr : int):
	super._init(instance_id, data)
	self.data = carddata

func get_data() -> PlayableCardData:
	return data	

func serialize() -> Dictionary:
	var output = super.serialize()
	output['data_id'] = data.get_id()
	output['rounds_in_hand'] = rounds_in_hand
	return output

func resync(serialized_obj : Dictionary) -> void:
	self.rounds_in_hand = serialized_obj['rounds_in_hand']
	super.resync(serialized_obj)

static func deserialize(serialized_obj : Dictionary, carddata : CardData) -> PlayableInstanceData:
	var instance := PlayableInstanceData.new("", carddata, 0)
	instance.resync(serialized_obj)
	instance.data = (carddata as PlayableCardData)
	return instance	


	 #CardLoader.get_card_data(serialized_obj['data_id'])

#func preview(board : BoardMatrixData, previewer : Callable, tile_pos : Vector2i) -> void:
	#return preview_event.preview(board, previewer, tile_pos)
	
	
#func placeable(board : BoardMatrixData, pos : Vector2i) -> bool:
	#for condition in place_conditions:
		#if !condition.test(board, pos):
			#return false
	#return true
