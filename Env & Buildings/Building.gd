extends Placeable
class_name Building

# in case we want buildings that can be placed ontop of other buildings
# dict contains which buildings this building can be stacked onto
@export var stackable_buildings : Dictionary = {}

# As defined in card_database
@export var AOE : String

# A dictionary of pairings (which are also dicts) describing how surrounding buildings
# in the AOE will contribute to scoring for this building
@export var AOE_scorers : Dictionary
