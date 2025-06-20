extends Object
class_name CardInstanceData
# Interface-like class to be overriden

var data_instance_id
var owner_uuid

func _init(data : CardData):
	pass

func get_data() -> CardData:
	return null	

func get_data_instance_id() -> int:
	return data_instance_id
