extends BoardEvent
class_name Score_BoardEffect

@export_category("Scoring")
@export var effect_buildings_score : Dictionary[String, int]
@export var base_score : int = 0

# TODO: This form of caching may pose a problem later?
# This assumes that the same typeof building (separate from buildingdata) will not have differences between one another
var cache_total_score : int = 0
var cache_position : Vector2i

# Actual code that uses the aoe to figure out which tiles should be scored, then assigns each tile a score
func score_tiles(board_matrix, tile_pos : Vector2i) -> Array[Array]:
	var score : int = 0
	
	# Returns an Array containg 2 Arrays of equal length, [[tilepos], [tiledata]]
	var tile_pos_data = aoe.get_scored_tiles(board_matrix, tile_pos)
	tile_pos_data.append([])
	
	# Assign a score to each tile based on its tiledata 
	for tile_data in tile_pos_data[1]:
		for building in tile_data.buildings:
			score += modifier(effect_buildings_score.get(building.data.id_name, 0), tile_data)
		tile_pos_data[2].append(score)
		score = 0
	# Array of arrays, [[tilepos], [tiledata], [tile_score]]
	return tile_pos_data

# Displays the textlabel scoring above each tile. Board calls this function during preview_placement
# Note that this does not finalize the scoring
func get_preview(board : Board, tile_pos : Vector2i) -> Array[Vector2i]:
	# Reset the cached score when recalculating, so we don't include old previews
	cache_total_score = 0
	
	var tile_pos_data_score = score_tiles(board, tile_pos)
	
	var tile_score : int
	for i in range(len(tile_pos_data_score[0])):
		tile_score = tile_pos_data_score[2][i]
		if tile_score != 0 :
			tile_pos_data_score[1][i].display_score(tile_score)
			cache_total_score += tile_score
	cache_position = tile_pos
	
	var arr : Array[Vector2i]
	arr.assign(tile_pos_data_score[0])
	return arr

func trigger(board : Board, tile_pos : Vector2i) -> void:
	# Checked if the scored tiles are different from the cached ones
	var total_score : int = 0
	
	# TODO: This form of caching may pose a problem later?
	# This assumes that buildings nodes with the same buildingdata are the same though that may not be true later
	# Try not to introduce a circular dependency
	if cache_total_score != 0 && cache_position != tile_pos:
		for score in score_tiles(board, tile_pos)[2]:
			total_score += score
	else:
		total_score = cache_total_score
		cache_total_score = 0
		cache_position = Vector2i.ZERO
	Signalbus.emit_signal("add_score", total_score)

# TO OVERRIDE
# In case we need to multiply / add score based on tile / building info
func modifier(score : int, tile_data : BoardTile):
	return score
