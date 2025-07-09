extends Node
class_name EventManager

# Dependencies
var matrix_data : BoardMatrixData

var id_to_instances : Dictionary[String, CardInstanceData]

var on_round_start_events : Array[Event]
var on_round_start_events_dict : Dictionary[String, Event]

var on_round_end_events : Array[Event]
var on_round_end_events_dict : Dictionary[String, Event]

# Dictionary[String, Dictionary] -> key is the name of the instance
# Dictionary[int, Event] -> key is the type of the event
var events : Dictionary[String, Dictionary]
var conditions : Dictionary[String, Dictionary]

func add_events(instance : CardInstanceData) -> void:
	events[instance.get_id()] = instance.get_data().get_events_as_dict()
	id_to_instances[instance.get_id()] = instance

## Remove all events related to this card instance
func clean_events(instance : CardInstanceData) -> void:
	pass
	
func modify_event(instruction : Dictionary) -> bool:
	return true

#func trigger_event(instance : CardInstanceData, event_type : String, params : Array) -> void:
	#var events_to_run : Array[Event]
	#events_to_run.assign(events[instance.get_id()][event_type])
	#
	#run_events(events_to_run, params)
#
#func check_condition(instance : CardInstanceData, condition_name : String, params : Array) -> bool:
	#var conditions_to_run : Array[Condition]
	#conditions_to_run.assign(events[instance.get_id()][condition_name])
	#return run_conditions(conditions_to_run, params)
	#pass
#
## Remove all events related to this card instance
#func clean_events(instance : CardInstanceData) -> void:
	#pass
#
#func run_conditions(conditions_to_check : Array[Condition], params : Array) -> bool:
	#for condition in conditions_to_check:
		#if condition is BoardCondition:
			#if !condition.test(matrix_data, params):
				#return false
	#return true
#
#func run_events(events_to_run : Array[Event], params : Array) -> void:
	#for event in events_to_run:
		#if event is BoardEvent:
			#event.trigger(matrix_data)
