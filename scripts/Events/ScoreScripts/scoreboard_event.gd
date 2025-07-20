extends BoardEvent
class_name ScoreEffect

@export_category("Scoring")
@export var effect_buildings_score : Dictionary[String, int]
@export var base_score : int = 0

# variables that can change by auras
var multiplier := 1.0
var addition := 0

# Actual code that uses the aoe to figure out which tiles should be scored, then assigns each tile a score
func score_tiles(_tile_pos : Vector2i) -> Array[Array]:
	return []

# Displays the textlabel scoring above each tile. Board calls this function during preview_placement
# Note that this does not finalize the scoring
func preview(board : BoardMatrixData, previewer : Callable, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	pass


func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	pass

# TO OVERRIDE
# In case we need to multiply / add score based on tile / building info
func modifier(score : int, _tile_data : BoardTile):
	return score
