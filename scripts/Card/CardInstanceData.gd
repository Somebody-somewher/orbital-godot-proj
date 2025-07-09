extends Object
class_name CardInstanceData

var data_instance_id : String
var owner_uuid : String

func _init(instance_id : String, data : CardData):
	data_instance_id = instance_id
	pass

func get_data() -> CardData:
	return null	

func set_owner_uuid(owner : String) -> void:
	owner_uuid = owner

func get_id() -> String:
	return data_instance_id

func get_owner_uuid() -> String:
	return owner_uuid

func serialize() -> Dictionary:
	var output = {}
	output['instance_id'] = data_instance_id
	output['owner_uuid'] = owner_uuid
	return output

func resync(serialized_obj : Dictionary) -> void:
	data_instance_id = serialized_obj['instance_id']
	owner_uuid = serialized_obj['owner_uuid']

static func deserialize(serialized_obj : Dictionary, data : CardData) -> CardInstanceData:
	var instance := CardInstanceData.new("", null)
	instance.resync(serialized_obj)
	return instance	
