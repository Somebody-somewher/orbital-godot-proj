extends Resource
class_name RoundState

signal transition_to
var update_round_count : Callable

@export var next_state_ids : Array[String]

@export var state_id : String
@export var time : float

func round_start() -> void:
	pass

func round_end() -> void:
	emit_signal("transition_to", next_state_ids[0])
	pass

func get_time() -> float:
	return time

func get_id() -> String:
	return state_id
