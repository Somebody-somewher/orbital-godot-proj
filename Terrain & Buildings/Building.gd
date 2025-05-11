extends Resource
class_name Building

@export var name : String
@export var image : Texture2D
# in case we want buildings that can be placed ontop of other buildings
# dict contains which buildings this building can be stacked onto
@export var stackable_buildings : Dictionary = {}

# Base score of placing this building down
@export var base_score : int = 0;

# As defined in card_database
@export var AOE : String

# A dictionary of pairings (which are also dicts) describing how surrounding buildings
# in the AOE will contribute to scoring for this building
@export var AOE_scorers : Dictionary
