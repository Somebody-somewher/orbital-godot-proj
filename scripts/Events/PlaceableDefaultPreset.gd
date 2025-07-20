extends PlayableDefaultPreset
class_name PlaceableDefaultPreset

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
