extends Object
class_name BoardMatrixData
# Data class that contains the actual Matrix of BoardTiles + Helper Function

# Contains a 2d Matrix of BoardTiles
var board_matrix

# Length/Width (no. cells) of board
var _board_size : int
var _boards_layout : Vector2i

var boards_coords : Array[Array]
var interactable : Array[bool]

var instances_on_board : Dictionary[String, BoardTile]

# Initialize 2d array matrix
func _init(board_size : int, boards_layout : Vector2i) -> void:
	Signalbus.get_tile_pos_from_AOE.connect(constrain_pattern_to_board)
	_board_size = board_size
	_boards_layout = boards_layout
	
	# Init matrix
	board_matrix = Array()
	interactable = []
	board_matrix.resize(board_size * boards_layout.x)
	interactable.resize(board_size * boards_layout.x)	
	
	for i in range(board_size * boards_layout.x):
		board_matrix[i] = Array()
		board_matrix[i].resize(board_size * boards_layout.y)
	
	# Get the start and end coordinates of each of the boards
	var start_pos : Vector2i
	var end_pos : Vector2i
	for y in range(boards_layout.y):
		for x in range(boards_layout.x):
			start_pos = Vector2i(x * board_size, y * board_size)
			end_pos = start_pos + Vector2i(board_size,board_size) - Vector2i(1,1)
			
			boards_coords.append([start_pos, end_pos])
		
	
## Create a board tile for each cell in the matrix (passed indirectly to procgen via board_manager)
func add_tile(tilePos : Vector2i, terrain_env : EnvTerrain) -> void:
	board_matrix[tilePos.x][tilePos.y] = BoardTile.new(terrain_env)

## Put a placeable on the board tile
func add_placeable_to_tile(tilePos : Vector2i, placeable : PlaceableInstanceData) -> void:
	board_matrix[tilePos.x][tilePos.y].add_placeable(placeable)
	instances_on_board[placeable.get_id()] = board_matrix[tilePos.x][tilePos.y]

func get_placeable(placeable_id : String) -> PlaceableInstanceData:
	if instances_on_board.has(placeable_id):
		return instances_on_board[placeable_id].get_building_on_tile(placeable_id)
	else:
		return null
		
func remove_placeable_on_tile(placeable_id : String) -> void:
	
	if instances_on_board.has(placeable_id):
		instances_on_board[placeable_id].delete_from_tile(placeable_id)
		instances_on_board.erase(placeable_id)
	else:
		printerr("Likely server has deleted the instance before client even added it lol")
		printerr("Decide how to handle this later")

## Change the terrain on the board tile
func change_terrain_of_tile(tilePos : Vector2i, terrain : EnvTerrain) -> void:
	board_matrix[tilePos.x][tilePos.y].change_terrain(terrain)

## Get the contents of the matrix tile
func get_tile(tilePos : Vector2i) -> BoardTile:
	return board_matrix[tilePos.x][tilePos.y]

func for_each_tile(c : Callable, tile_positions : Array[Vector2i] = []):
	if tile_positions.is_empty():
		for row in range(_board_size):
			for col in range(_board_size):
				c.call(board_matrix[row][col])
	else:
		for pos in tile_positions:
			c.call(board_matrix[pos.x][pos.y])

func for_each_building(c : Callable) -> void:
	for tile in instances_on_board.values():
		tile.foreach_building_on_tile(c)

func constrain_pattern_to_board(tile_pos : Vector2i, pattern_arr : Array[Vector2i], output_tile_pos : Array[Array]) -> void:
	for i in len(pattern_arr):
		var true_tile = pattern_arr[i] + tile_pos
		if _tile_on_board(true_tile):
			output_tile_pos[0].append(true_tile)
			output_tile_pos[1].append(get_tile(true_tile))

func _tile_on_board(pos : Vector2i) -> bool:
	return pos == pos.clamp(boards_coords[0][0], boards_coords[len(boards_coords) - 1][1])

func search_matrix_readonly(c : Callable):
	c.call(board_matrix)

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

## Get the start-end board coordinates of the board the tilepos is in, 
## if the tilepos is in an interactable board
func get_interactable_boardcoords_of_tilepos(tilepos : Vector2i) -> Array:
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

func reset() -> void:
	Signalbus.get_tile_pos_from_AOE.disconnect(constrain_pattern_to_board)
