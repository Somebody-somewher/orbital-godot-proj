extends Resource
class_name BuildingData

# Set any of the given tags from the editor
# In case we need to quickly figure out whether the building has a special synergy or typing
# TODO: Put this in the Conditions and Effect classes, then when loading the building in
# retrieve all the synergies from the Effects and Conditions and collate 'em here 
@export_flags("Moo", "Rat", "Waterproof", "Wall") var synergies = 0

# Which pack this building belongs to
@export_flags("Dummy Set", "Big Cow Set", "Nature Set", "Cute Dummy Set") var pack_set = 0

#Event
@export var building_name : String
@export var sprite : Texture2D
@export var base_score : int

#################################### EFFECTS ##########################################
# Effects basically consists of a series of abstracted functions using Godot's resources
# https://www.youtube.com/watch?v=vzRZjM9MTGw&t=112s

# Conditions follow the same sortof logic

# Conditions on what kind of terrain / conditions this building can be placed on
@export var placement_predicate : Condition

# Effects that trigger once the building is placed
# Scoring will be done here 
@export var place_effects : Array[Effect]

@export var begin_round_effects : Array[Effect]

@export var end_round_effects : Array[Effect]

@export var destroyed_effects : Array[Effect]

# If a certain board condition is met, perform the effect
# For example, maybe the building does something if a certain amount of other buildings exist
# Array of Condition-Effect Pairs
# Would probably need a hook for this to not lag? Idk see how later
@export var condition_effect : Array[Array]

func trigger_events(effects : Array[Effect]):
	for effect in effects:
		if effect != null and effect.has_method("trigger_effect"):
			# May need to interact with the Board, the CardManager, the Score System, etc
			# Should effect use an eventbus?
			effect.trigger_effect(self)

func _on_place():
	trigger_events(place_effects)

func _on_round_begin():
	trigger_events(begin_round_effects)

func _on_round_end():
	trigger_events(end_round_effects)

func _on_destroyed():
	trigger_events(destroyed_effects)
