extends Resource
class_name RoundState

signal transition_to

@export var next_state_ids : Array[String]

@export var state_id : String
@export var time : float

func round_start() -> void:
	pass

func round_end() -> void:
	transition_to.emit(next_state_ids[0])
	pass

func get_time() -> float:
	return time

func get_id() -> String:
	return state_id

func reset() -> void:
	pass
