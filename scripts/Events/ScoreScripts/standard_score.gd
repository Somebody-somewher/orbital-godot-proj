extends ScoreEffect
class_name StandardScore

var affected_tiles : Array[Vector2i] 

func trigger(id_name : String, board_matrix, tile_pos : Vector2i) -> void:
	lazy_score = 0
	for highlight_tile_pos in affected_tiles:
		lazy_score += database_ref.get_tile_score(board_matrix[highlight_tile_pos.x][highlight_tile_pos.y].buildings_name_arr, id_name)
	signal_add_score(lazy_score)

func calculate_and_display_scoring(id_name : String, board : Board, tile_pos : Vector2i) -> void:
	affected_tiles = database_ref.get_card_aoe_by_id(id_name)
	affected_tiles = board.constrain_pattern_to_board(affected_tiles, tile_pos)
	board.affected_tiles = affected_tiles
	for highlight_tile_pos in affected_tiles:
		board.highlight_tile(highlight_tile_pos, true)
		var highlight_tile: BoardTile = board.get_tile(highlight_tile_pos)
		_calculate_and_display(highlight_tile, id_name)

func _calculate_and_display(tile : BoardTile, building_id : String) -> void :
	var score = database_ref.get_tile_score(tile.buildings_name_arr, building_id)
	if score != 0 :
		tile.display_score(score)
