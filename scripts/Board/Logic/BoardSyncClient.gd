extends Node

var local_board_matrix : BoardMatrixData
var boards_coords : Array[Array]
var interactable : Array[bool]
var _boards_layout : Vector2i

# Initialize 2d array matrix
func _init(board_size : int, boards_layout : Vector2i) -> void:
	local_board_matrix = BoardMatrixData.new(board_size, boards_layout)
	boards_coords = local_board_matrix.boards_coords
	interactable = local_board_matrix.interactable
	_boards_layout = local_board_matrix._boards_layout
	
## Get start-end coords of playable 
func get_playable_area_coords() -> Array[Vector2i]:
	return [boards_coords[0][0], boards_coords[len(boards_coords) - 1][1]]

################################ TILEPOS QUERIES ###############################

## Check if tilepos inside playable area
func check_tilepos_in_playable(tilepos : Vector2i) -> bool:
	if tilepos.x >=  boards_coords[0][0].x and tilepos.x <= boards_coords[len(boards_coords) - 1][1].x:
		if tilepos.y >= boards_coords[0][0].y and tilepos.y <= boards_coords[len(boards_coords) - 1][1].y:
			return true
	return false

func check_tilepos_in_layout_coords(tilepos : Vector2i, boardlayout_pos : Vector2i) -> bool:
	return _check_tilepos_in_board(tilepos, layout_to_boardcoords(boardlayout_pos))

## Get the start-end coordinates of the board the tilepos is in
func get_boardcoords_of_tilepos(tilepos : Vector2i) -> Array:
	for i in range(len(boards_coords)):
		if interactable[i] and _check_tilepos_in_board(tilepos, boards_coords[i]):
			return boards_coords[i]
	return []

## Check if tilepos exists in a given board coords
func _check_tilepos_in_board(tilepos : Vector2i, board_start_end_pos : Array) -> bool:
	if tilepos.x >=  board_start_end_pos[0].x and tilepos.x <= board_start_end_pos[1].x:
		if tilepos.y >= board_start_end_pos[0].y and tilepos.y <= board_start_end_pos[1].y:
			return true
	return false

func layout_to_boardcoords(boardlayout_pos : Vector2i) -> Array[Vector2i]:
	assert(boardlayout_pos.x <= _boards_layout.x and boardlayout_pos.y <= _boards_layout.y)
	var output : Array[Vector2i]
	
	var index : int = boardlayout_pos.x + (boardlayout_pos.y - 1) * _boards_layout.x - 1
	output.assign(boards_coords[index])
	return output

######################################################################################

func set_board_interactable(boardlayout_pos : Vector2i) -> Array:
	assert(boardlayout_pos.x <= _boards_layout.x and boardlayout_pos.y <= _boards_layout.y)
	var index : int = boardlayout_pos.x + (boardlayout_pos.y - 1) * _boards_layout.x - 1
	interactable[index] = true
	return boards_coords[index]
