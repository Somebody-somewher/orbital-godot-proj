extends CardData
class_name PlaceableData
# Tiles, Terrain or etc
@export_category("Basic Properties")
@export var id_name : String
@export var display_name : String

# Description to show the user whenever they select or hover over the card?
@export_multiline var desc : String

@export_category("Tags and Combos")
enum Category { 
	SABOTAGE, ECONOMY, RELIGION, 
	INFRASTRUCTURE, FARMING, SCIENCE, 
	CULTURE, NATURE, INDUSTRY, POWER }

# influences some auras and card back colour
@export var category: Category
@export var tags : Array[String]

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
@export var place_effects : Array[BoardEvent]
@export var post_place_effects : Array[BoardEvent]
@export var begin_round_effects : Array[BoardEvent]
@export var end_round_effects : Array[BoardEvent]
@export var destroyed_effects : Array[BoardEvent]

func preview(board : BoardMatrixData, previewer : Callable, tile_pos : Vector2i) -> void:
	return preview_event.preview(board, previewer, tile_pos)
	
func placeable(board : BoardMatrixData, pos : Vector2i) -> bool:
	for condition in place_conditions:
		if !condition.test(board, pos):
			return false
	return true
