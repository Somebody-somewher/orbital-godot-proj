extends Object
class_name ProcGenBoardIterator

var _matrix : Array

var _board_size : Vector2i
var _board_num_width_height : Vector2i
var _border_width : Vector2i

var board_start_tile : Vector2i
var curr_board : Vector2i

var cache : Dictionary

func _init(matrix : Array, board_size : Vector2i, board_num : Vector2i, border_width : Vector2i) -> void:
	_matrix = matrix
	_board_size = board_size
	_board_num_width_height = board_num
	_border_width = border_width
	
	reset_board()
	
func foreach_tile_in_board(c : Callable):
	if curr_board == Vector2i(0,1):
		next_board()
		
	var element 
	for y in range(_board_size.y):
		for x in range(_board_size.x):
			element = _matrix[board_start_tile.y + y][board_start_tile.x + x]
			if element != null:
				c.call(element.get_id(), Vector2i(board_start_tile.x + x,board_start_tile.y + y))

func reset_board() -> void:
	board_start_tile = Vector2i(_border_width.x, _border_width.y)
	curr_board = Vector2i(0,1)


func next_board() -> bool:
	if curr_board.y > _board_num_width_height.y:
		return false
		
	curr_board.x += 1
	
	if curr_board.x > _board_num_width_height.x:
		curr_board.y += 1
		curr_board.x = 1
		if curr_board.y > _board_num_width_height.y:
			return false
			
	board_start_tile.x = _border_width.x + (curr_board.x - 1) * _board_size.x
	board_start_tile.y = _border_width.y + (curr_board.y - 1) * _board_size.y
	#print(board_start_tile)
	return true

func skip_to_board(board_id : int) -> void:
	reset_board()
	for i in range(board_id + 1):
		next_board()

func retrieve_matrix() -> Array:
	return _matrix

func foreach_ele(o : Object, c : Callable) -> void:
	if o in cache.keys():
		for pos in cache.get(o):
			c.call(_matrix[pos.y][pos.x].get_id(), Vector2i(pos.x,pos.y))

func foreach_ele_in_board(o : Object, c : Callable) -> void:
	if cache.has(o):
		for pos in cache.get(o):
			if pos.x >= board_start_tile.x and pos.x < board_start_tile.x + _board_num_width_height.x \
				and pos.y >= board_start_tile.y and  pos.y < board_start_tile.y + _board_num_width_height.y:
				c.call(_matrix[pos.y][pos.x].get_id(), Vector2i(pos.x,pos.y))

func foreach_border(c : Callable) -> void:
	var ylen : int = len(_matrix) 
	var xlen : int = len(_matrix[0]) 
	for y in range(ylen):
		for x in range(_border_width.x):
			if _matrix[y][x]:
				c.call(_matrix[y][x].get_id(), Vector2i(x,y))
			if _matrix[y][xlen-1-x]:
				c.call(_matrix[y][xlen-1-x].get_id(), Vector2i(xlen-1-x,y))
	
	for y in range(_border_width.y):
		for x in range(_border_width.x, xlen-_border_width.x):
			if _matrix[y][x]:
				c.call(_matrix[y][x].get_id(), Vector2i(x,y))
			if _matrix[ylen-1-y][x]:
				c.call(_matrix[ylen-1-y][x].get_id(), Vector2i(x,ylen-1-y))
