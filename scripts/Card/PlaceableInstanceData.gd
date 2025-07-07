extends CardInstanceData
class_name PlaceableInstanceData

var data : PlaceableData

func _init(instance_id : String, data : PlaceableData, card_attr : int):
	super._init(instance_id, data)
	self.data = data

func get_data() -> BuildingData:
	return data	

#func preview(board : BoardMatrixData, previewer : Callable, tile_pos : Vector2i) -> void:
	#return preview_event.preview(board, previewer, tile_pos)
	#
#func placeable(board : BoardMatrixData, pos : Vector2i) -> bool:
	#for condition in place_conditions:
		#if !condition.test(board, pos):
			#return false
	#return true
