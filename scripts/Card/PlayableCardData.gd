extends CardData
class_name PlayableCardData

@export_category("Events and Conditions")
#################################### EFFECTS ##########################################
@export var default_preset : PlayableDefaultPreset
	
# predicates in the form of pred(self id in database, board, pos)
@export var play_conditions : Array[Condition] 

@export var play_effects : Array[Event]
@export var discard_effects : Array[Event]

func load_default_preset() -> void:
	if default_preset:
		super.load_default_preset()
		if play_conditions.is_empty() and !override_default:
			play_conditions = default_preset.play_conditions.duplicate()
			
		if play_effects.is_empty() and !override_default:
			play_effects = default_preset.play_effects.duplicate()
		
		if discard_effects.is_empty() and !override_default:
			discard_effects = default_preset.discard_effects.duplicate()

func get_events_as_dict() -> Dictionary[String, Array]:
	var output : Dictionary[String,Array] = {}
	output['is_playable'] = play_conditions
	output['on_play'] = play_effects
	output['on_discard'] = discard_effects
	return output
