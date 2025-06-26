extends Object
class_name CardInstanceData

var data_instance_id : String
var owner_uuid

func _init(instance_id : String, data : CardData):
	data_instance_id = instance_id
	pass

func get_data() -> CardData:
	return null	

func get_id() -> String:
	return data_instance_id


 
