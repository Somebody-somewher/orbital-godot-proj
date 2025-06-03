extends ScoreBoardEffect
class_name StandardScoreEffect

# Actual code that uses the aoe to figure out which tiles should be scored, then assigns each tile a score
func score_tiles(tile_pos : Vector2i) -> Array[Array]:
	var score : int = 0
	
	# Returns an Array containg 2 Arrays of equal length, [[tilepos], [tiledata]]
	var tile_pos_data = aoe.get_scored_tiles(tile_pos)
	tile_pos_data.append([])
	
	# Assign a score to each tile based on its tiledata 
	for tile_data in tile_pos_data[1]:
		for building in tile_data.placeable_arr:
			score += modifier(effect_buildings_score.get(building.data.id_name, 0), tile_data)
		tile_pos_data[2].append(score)
		score = 0
		
	# Array of arrays, [[tilepos], [tiledata], [tile_score]]
	return tile_pos_data

# Displays the textlabel scoring above each tile. Board calls this function during preview_placement
# Note that this does not finalize the scoring
func preview(board : Board, previewer : Callable, tile_pos : Vector2i) -> void:
	# Reset the cached score when recalculating, so we don't include old previews
	cache_total_score = 0
	var tile_pos_arr : Array[Vector2i]
	var scores : Array[int]
	
	var tile_pos_data_score = score_tiles(tile_pos)
	
	for i in range(len(tile_pos_data_score[0])):
		tile_pos_arr.append(tile_pos_data_score[0][i])
		scores.append(tile_pos_data_score[2][i])
		cache_total_score += tile_pos_data_score[2][i]
	cache_position = tile_pos
	previewer.call(tile_pos_arr, scores)


func trigger(_board : Board, tile_pos : Vector2i) -> void:
	# Checked if the scored tiles are different from the cached ones
	var total_score : int = 0
	
	if cache_total_score:
		total_score = cache_total_score
	else:
		# Force a recalculation of the score
		for score in score_tiles(tile_pos)[2]:
			total_score += score
			
	Signalbus.emit_signal("add_score", total_score)

# TO OVERRIDE
# In case we need to multiply / add score based on tile / building info
func modifier(score : int, tile_data : BoardTile):
	return score
