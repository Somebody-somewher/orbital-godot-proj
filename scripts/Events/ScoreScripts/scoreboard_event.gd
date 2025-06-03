extends BoardEvent
class_name ScoreBoardEffect

@export_category("Scoring")
@export var effect_buildings_score : Dictionary[String, int]
@export var base_score : int = 0

# TODO: This form of caching may pose a problem later?
# This assumes that the same typeof building (separate from buildingdata) will not have differences between one another
var cache_total_score : int
var cache_position : Vector2i

# Actual code that uses the aoe to figure out which tiles should be scored, then assigns each tile a score
func score_tiles(tile_pos : Vector2i) -> Array[Array]:
	return []

# Displays the textlabel scoring above each tile. Board calls this function during preview_placement
# Note that this does not finalize the scoring
func preview(board : Board, previewer : Callable, tile_pos : Vector2i) -> void:
	pass


func trigger(_board : Board, _tile_pos : Vector2i) -> void:
	pass

# TO OVERRIDE
# In case we need to multiply / add score based on tile / building info
func modifier(score : int, tile_data : BoardTile):
	return score
