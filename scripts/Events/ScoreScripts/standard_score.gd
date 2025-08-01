extends ScoreEffect
class_name StandardScoreEffect

# Actual code that uses the aoe to figure out which tiles should be scored, then assigns each tile a score
func score_tiles(tile_pos : Vector2i) -> Array[Array]:
	var score : int = 0
	
	# Returns an Array containg 2 Arrays of equal length, [[tilepos], [tiledata]]
	var tile_pos_data = aoe.get_scored_tiles(tile_pos)
	
	tile_pos_data.append([])
	# Assign a score to each tile based on its tiledata 
	for tile_data in tile_pos_data[1]:
		tile_pos_data[2].append(modifier(tile_data))
		
	# Array of arrays, [[tilepos], [tiledata], [tile_score]]
	return tile_pos_data

# Displays the textlabel scoring above each tile. Board calls this function during preview_placement
# Note that this does not finalize the scoring
func preview(board : BoardMatrixData, previewer : Callable, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	# Reset the cached score when recalculating, so we don't include old previews
	var tile_pos_arr : Array[Vector2i]
	var scores : Array[int]
	
	var tile_pos_data_score = score_tiles(tile_pos)
	
	for i in range(len(tile_pos_data_score[0])):
		tile_pos_arr.append(tile_pos_data_score[0][i])
		scores.append(tile_pos_data_score[2][i])
	previewer.call(tile_pos_arr, scores)

func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	# Checked if the scored tiles are different from the cached ones
	var total_score : int = 0
	
	var data_array = score_tiles(tile_pos)
	# recalculation of the score
	for score in data_array[2]:
		total_score += score
	
	if total_score > 0:
		Signalbus.emit_signal("add_score", total_score, caller.get_owner_uuid())
		Signalbus.call_point_fx.emit(total_score, tile_pos, caller.get_owner_uuid())

# In case we need to multiply / add score based on tile / building info
func modifier(tile_data : BoardTile, _cum_score := 0) -> int:
	var score := 0
	for building in tile_data.get_buildings_on_tile():
		score += effect_buildings_score.get(building.data.id_name, 0)
	return score
	#return (score + addition) * multiplier
