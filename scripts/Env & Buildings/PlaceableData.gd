extends PlayableCardData
class_name PlaceableData

@export_category("Events and Conditions")
#################################### EFFECTS ##########################################
# Effects basically consists of a series of abstracted functions using Godot's resources
# https://www.youtube.com/watch?v=vzRZjM9MTGw&t=112s

# Every placeable will likely have a preview on the board.
# Whether be it scoring/non-scoring events for buildings or AOE for sabotage
# So this is the main preview when you select a card and hover over the board with it
@export var preview_event : BoardEvent 

# predicates in the form of pred(self id in database, board, pos)
@export var place_conditions : Array[Condition] 

# Effects that trigger once the building is placed
# Scoring will be done here 
# TODO: May lump this up into one class called EventGroup for the inheritance
@export var place_effects : Array[Event]
@export var post_place_effects : Array[Event]
@export var begin_round_effects : Array[Event]
@export var end_round_effects : Array[Event]
@export var destroyed_effects : Array[Event]

func load_default_preset() -> void:
	super.load_default_preset()
	place_conditions = default_preset.place_conditions
	place_effects = default_preset.place_effects
	post_place_effects = default_preset.post_place_effects
	begin_round_effects = default_preset.begin_round_effects
	end_round_effects = default_preset.end_round_effects
	destroyed_effects = default_preset.destroyed_effects
	pass

func get_events_as_dict() -> Dictionary[String, Array]:
	var output = super.get_events_as_dict()
	output['is_placeable'] = place_conditions
	output['on_place'] = place_effects
	output['on_destroy'] = destroyed_effects
	output['post_place'] = post_place_effects
	output['on_begin_round'] = begin_round_effects
	output['on_end_round'] = end_round_effects
	
	return output
