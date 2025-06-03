extends Object
class_name BoardMatrixData
# Dataa class that contains the actual Matrix of BoardTiles + Helper Function

# Contains a 2d Matrix of BoardTiles
var board_matrix

# Length/Width (no. cells) of board
var BOARD_SIZE : int

# Initialize 2d array matrix
func _init(board_size : int) -> void:
	Signalbus.connect("get_tile_pos_from_AOE",constrain_pattern_to_board)
	Signalbus.connect("run_search_on_board", search_matrix_readonly)
	BOARD_SIZE = board_size
	board_matrix = Array()
	board_matrix.resize(BOARD_SIZE)
	
	for i in range(BOARD_SIZE):
		board_matrix[i] = Array()
		board_matrix[i].resize(BOARD_SIZE)

func add_tile(tilePos : Vector2i, terrain_env : EnvTerrain) -> void:
	board_matrix[tilePos.x][tilePos.y] = BoardTile.new(terrain_env)
	
func add_placeable_to_tile(tilePos : Vector2i, placeable : PlaceableNode) -> void:
	board_matrix[tilePos.x][tilePos.y].add_placeable(placeable)

func get_tile(tilePos : Vector2i) -> BoardTile:
	return board_matrix[tilePos.x][tilePos.y]

func for_each_tile(c : Callable, tile_positions : Array[Vector2i] = []):
	if tile_positions.is_empty():
		for row in range(BOARD_SIZE):
			for col in range(BOARD_SIZE):
				c.call(board_matrix[row][col])
	else:
		for pos in tile_positions:
			c.call(board_matrix[pos.x][pos.y])
			
func constrain_pattern_to_board(tile_pos : Vector2i, pattern_arr : Array[Vector2i], output_tile_pos : Array[Array]) -> void:
	for i in len(pattern_arr):
		var true_tile = pattern_arr[i] + tile_pos
		if true_tile == true_tile.clampi(0, BOARD_SIZE - 1):
			output_tile_pos[0].append(true_tile)
			output_tile_pos[1].append(get_tile(true_tile))

func search_matrix_readonly(c : Callable) -> void:
	c.call(board_matrix)
