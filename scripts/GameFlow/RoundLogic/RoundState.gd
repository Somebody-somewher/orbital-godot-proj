extends Resource
class_name RoundState

signal transition_to

@export var next_state : RoundState

@export var state_id : String
@export var time : float

func round_start() -> void:
	pass

func round_end() -> void:
	emit_signal("transition_to", next_state)
	pass

func get_time() -> float:
	return time
