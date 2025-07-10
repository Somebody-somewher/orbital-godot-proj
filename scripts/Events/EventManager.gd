extends Node
class_name EventManager

# Dependencies
var matrix_data : BoardMatrixData
var card_mem : Dictionary[String, PlayerCardMemory]

var id_to_instances : Dictionary[String, CardInstanceData]

var on_round_start_events : Array[Event]
var on_round_start_events_dict : Dictionary[String, Event]

var on_round_end_events : Array[Event]
var on_round_end_events_dict : Dictionary[String, Event]

# Dictionary[String, Dictionary] -> key is the name of the instance
# Dictionary[int, Event] -> key is the type of the event
var events_and_conditions : Dictionary[String, Dictionary]

func setup_mem(mem : Dictionary[String, PlayerCardMemory]) -> void:
	var player_mems : Array[PlayerCardMemory] = mem.values()
	for pm in player_mems:
		pm.event_manager_setup(add_events, trigger_play_events, trigger_discard_events)

func add_events(instance : CardInstanceData) -> void:
	var events_dict := instance.get_data().get_events_as_dict()
	var instance_id := instance.get_id()
	#for event_arr in events_dict.values():
		#for e in event_arr:
			#e.connect("request_modification", modify_event)
	
	events_and_conditions[instance_id] = events_dict
	#print(events_dict)
	id_to_instances[instance_id] = instance

	# TODO: Make a clearer system
	if events_dict["preview"][0] not in events_and_conditions[instance_id]["on_place"]:
		events_and_conditions[instance_id]["on_place"].push_front(events_dict["preview"][0])

## Remove all events related to this card instance
func clean_events(instance : CardInstanceData) -> void:
	pass

@rpc("any_peer", "call_local")
func modify_event(instruction : Dictionary) -> bool:
	return true

func preview_event(instance : CardInstanceData, previewer : Callable, tilepos : Vector2i) -> void:
	var event_to_run = events_and_conditions[instance.get_id()]["preview"][0]
	if event_to_run is BoardEvent:
		event_to_run.preview(matrix_data, previewer, tilepos, instance)

func trigger_discard_events(instance : CardInstanceData) -> void:
	pass
	
func trigger_play_events(instance : CardInstanceData) -> void:
	pass

func trigger_place_events(instance : CardInstanceData, tilepos : Vector2i) -> void:
	#print(events_and_conditions[instance.get_id()])
	run_events(events_and_conditions[instance.get_id()]["on_place"], instance, [tilepos])

func trigger_postplace_events(instance : CardInstanceData, tilepos : Vector2i) -> void:
	run_events(events_and_conditions[instance.get_id()]["post_place"], instance, [tilepos])

func check_card_play_conditions(instance : CardInstanceData) -> bool:
	return true

func check_place_conditions(instance : CardInstanceData, tilepos : Vector2i) -> bool:
	return run_conditions(events_and_conditions[instance.get_id()]["is_placeable"], instance, [tilepos])

	


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
func run_conditions(conditions_to_check : Array[Condition], source : CardInstanceData, params : Array) -> bool:
	for condition in conditions_to_check:
		if condition is BoardCondition and params[0] is Vector2i:
			if !condition.test(matrix_data, params[0], source):
				return false
	return true
#
func run_events(events_to_run : Array[Event], source : CardInstanceData, params : Array) -> void:
	for event in events_to_run:
		if event is BoardEvent and params[0] is Vector2i:
			event.trigger(matrix_data, params[0], source)
