extends Resource
class_name Condition

# The request is in the following format:
# Dictionary[String, Dictionary] -> CardInstanceDataID as key
# -> Dictionary[Event, Dictionary] -> Event as key
# -> Dictionary[String, Array[MODIFICATION_TYPE, modified_value]] -> variable_name as key
signal request_modification(Dictionary)

# Pop-up msg explain to the user why they cant place the placeable or why something is happenin?
@export_multiline var reminder_msg : String

var return_bool := true

# SET is =, ADJUST is += or -= or sth liddat
enum MODIFICATION_TYPE {SET, ADJUST}

# Dictionary input
# Dictionary[Variable_name as String, Array[MODIFICATION_TYPE, modified_value]] -> variable_name as key
func process_modification(_to_modify : Dictionary[String, Array]) -> void:
	return
