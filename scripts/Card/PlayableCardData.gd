extends CardData
class_name PlayableCardData

@export_category("Events and Conditions")
#################################### EFFECTS ##########################################
@export var default_preset : PlayableDefaultPreset
	
# predicates in the form of pred(self id in database, board, pos)
@export var play_conditions : Array[Condition] 

@export var play_effects : Array[Event]
@export var discard_effects : Array[Event]

func get_events_as_dict() -> Dictionary[String, Array]:
	var output : Dictionary[String,Array] = {}
	output['is_playable'] = play_conditions
	output['on_play'] = play_effects
	output['on_discard'] = discard_effects
	return output
