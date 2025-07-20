extends Resource
class_name Event

@export
var event_name : String

@export
var desc : String
# The request is in the following format:
# Dictionary[String, Dictionary] -> CardInstanceDataID as key
# -> Dictionary[String, Dictionary] -> event_name as key
# -> Dictionary[String, Array[MODIFICATION_TYPE, modified_value]] -> variable_name as key
signal request_modification(Dictionary)

# SET is =, ADJUST is += or -= or sth liddat
enum MODIFICATION_TYPE {SET, ADJUST}

#enum EVENT_TYPE {ON_PLAY, ON_DISCARD, ON_PLACE, ON_DESTROY, ON_ROUND_START, ON_ROUND_END, PREVIEW}
#@export var type_of_event : EVENT_TYPE

# Dictionary input
# Dictionary[Variable_name as String, Array[MODIFICATION_TYPE, modified_value]] -> variable_name as key
func process_modification(to_modify : Dictionary[String, Array]) -> void:
	return
