extends Node
class_name EventManager

const EventKeys : Array = ["preview", "on_play", "on_discard", \
"on_place", "on_destroy", "post_place", "board_begin_round", "board_end_round"]

const ConditionKeys : Array = ["is_placeable"]

# Dependencies
var matrix_data : BoardMatrixData
var card_mem : CardMemory #: Dictionary[String, PlayerCardMemory]

# Dictionary[String, Pair[CardInstanceData, Array[Event]]] -> key is the id of the instance
var board_round_start_events_dict : Dictionary[String, Array]
var board_round_end_events_dict : Dictionary[String, Array]

var func_get_card_data : Callable

# Dictionary[String, Dictionary] -> key is the id of the instance
# Dictionary[int, Event] -> key is the type of the event
var events_and_conditions : Dictionary[String, Dictionary]

func setup_mem(mem : CardMemory, get_card_data : Callable) -> void:
	mem.event_manager_setup(register_events, trigger_events)
	card_mem = mem
	Signalbus.round_start.connect(func(round_id : String, round_total : int):\
		run_round_events(board_round_start_events_dict))
	Signalbus.round_end.connect(func(round_id : String, round_total : int):\
		run_round_events(board_round_end_events_dict))
	#func_get_card_data = get_card_data

func register_board_round_events(instance : CardInstanceData) -> void:
	assert(events_and_conditions.has(instance.get_id()))
	
	if !events_and_conditions[instance.get_id()]["board_begin_round"].is_empty():
		board_round_start_events_dict[instance.get_id()] = [instance, events_and_conditions[instance.get_id()]["board_begin_round"]]
	
	if !events_and_conditions[instance.get_id()]["board_end_round"].is_empty():
		board_round_end_events_dict[instance.get_id()] = [instance, events_and_conditions[instance.get_id()]["board_end_round"]]

func register_events(instance : CardInstanceData) -> void:
	var events_dict : Dictionary[String, Array] = instance.get_data().get_events_as_dict()
	events_and_conditions[instance.get_id()] = events_dict
	#print(events_dict)
	#id_to_instances[instance_id] = instance

	# TODO: Make a clearer system
	if events_dict["preview"][0] not in events_and_conditions[instance.get_id()]["on_place"]:
		events_and_conditions[instance.get_id()]["on_place"].push_front(events_dict["preview"][0])
	
	#if !events_dict["on_begin_round"].is_empty():
		#on_round_start_events_dict[instance.get_id()] = [instance, events_dict["on_begin_round"]]		
	#
	#if !events_dict["on_end_round"].is_empty():
		#on_round_end_events_dict[instance.get_id()] = [instance, events_dict["on_end_round"]]	

## Remove all events related to this card instance
func clean_events(instance : CardInstanceData) -> void:
	events_and_conditions.erase(instance.get_id())
	pass

@rpc("any_peer", "call_local")
func modify_event(instruction : Dictionary) -> bool:
	return true

func preview_event(instance : CardInstanceData, previewer : Callable, tilepos : Vector2i) -> void:
	var event_to_run = events_and_conditions[instance.get_id()]["preview"][0]
	if event_to_run is BoardEvent:
		event_to_run.preview(matrix_data, previewer, tilepos, instance)

func trigger_events(instance : CardInstanceData, event_id : String, params := []) -> void:
	assert(EventKeys.has(event_id))
	run_events(events_and_conditions[instance.get_id()][event_id], instance, params)

func check_conditions(instance : CardInstanceData, condition_id : String, params := []) -> bool:
	assert(ConditionKeys.has(condition_id))
	return run_conditions(events_and_conditions[instance.get_id()][condition_id], instance, params)

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
		run_event(event, source, params)

func run_round_events(events_to_run : Dictionary[String, Array]) -> void:
	for instance in events_to_run.keys():
		if instance is BuildingInstanceData:
			run_events(events_to_run[instance][1], events_to_run[instance][0], [instance.tile_pos])
		else:
			run_events(events_to_run[instance][1], events_to_run[instance][0], [])

func run_event(event : Event, source : CardInstanceData, params : Array) -> void:
	if event is BoardEvent:
		if params.is_empty():
			event.trigger(matrix_data, (source as PlaceableInstanceData).tile_pos, source)
		elif params[0] is Vector2i:
			event.trigger(matrix_data, params[0], source)
	elif event is CardEvent:
		event.trigger(card_mem, source)
	elif event is BaseScoreEvent:
		event.trigger(source)
#func run_all_round_events(events_to_run : Dictionary[CardInstanceData, Event]) -> void:
	#for instance in events_to_run.keys():
		#if event is events_to_run[instance]:
			#event.trigger(matrix_data, )

func reset_mem() -> void:
	#card_mem.clear()
	matrix_data = null
	card_mem = null
	board_round_start_events_dict.clear()
	board_round_end_events_dict.clear()
	events_and_conditions.clear()


#func trigger_discard_events(instance : CardInstanceData) -> void:
	#run_events(events_and_conditions[instance.get_id()]["on_discard"], instance, [])
	#pass
	#
#func trigger_play_events(instance : CardInstanceData) -> void:
	#run_events(events_and_conditions[instance.get_id()]["on_play"], instance, [])
	#pass
#
#func trigger_place_events(instance : CardInstanceData) -> void:
	#run_events(events_and_conditions[instance.get_id()]["on_place"], instance, [tilepos])
	#
#func trigger_destroy_events(instance : CardInstanceData) -> void:
	#run_events(events_and_conditions[instance.get_id()]["on_destroy"], instance, [tilepos])
#
#func trigger_postplace_events(instance : CardInstanceData) -> void:
	#run_events(events_and_conditions[instance.get_id()]["post_place"], instance, [tilepos])
#
#func trigger_round_start_events(instance : CardInstanceData, params : Array) -> void:
	#run_events(events_and_conditions[instance.get_id()]["on_begin_round"], instance, params[0])
	#pass
#
#func trigger_round_end_events(instance : CardInstanceData, params : Array) -> void:
	#run_events(events_and_conditions[instance.get_id()]["on_end_round"], instance, params[0])
	#pass	
#
#func check_card_play_conditions(instance : CardInstanceData) -> bool:
	#return true
#
#func check_place_conditions(instance : CardInstanceData, tilepos : Vector2i) -> bool:
	#return run_conditions(events_and_conditions[instance.get_id()]["is_placeable"], instance, [tilepos])
