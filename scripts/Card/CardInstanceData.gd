extends Object
class_name CardInstanceData
# Interface-like class to be overriden
static var card_count := 0

var data_instance_id : String
var owner_uuid

func _init(data : CardData):
	data_instance_id = (data.get_id() + "|" + str(increment_card_count()) + "|" + str(randi())).sha1_text()
	pass

static func increment_card_count() -> int:
	card_count += 1
	return card_count

func get_data() -> CardData:
	return null	

func get_id() -> String:
	return data_instance_id
	
 
