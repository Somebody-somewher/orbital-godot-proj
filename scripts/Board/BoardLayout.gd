extends Object
class_name BoardLayout


var BOARDS_LAYOUT : Vector2i

# UserID -> Array of BoardIds
# the board ids are the boards this player controls during build phase
var player_native_boards : Dictionary[int, Array]

# UserID -> Array of BoardIds
# the board ids represent the boards that the player can interact with
var player_interactable_boards : Dictionary[int, Array]

# Boards currently in use by players
var used_boards : Array

var _set_interactable_func : Callable

var starting_player_board : Vector2i = Vector2i(1,1)
var curr_player_board : Vector2i = starting_player_board

func _init(set_interactable_func : Callable) -> void:
	_set_interactable_func = set_interactable_func
	
func get_board_layout(num_players : int) -> Vector2i:
	match num_players:
		0:
			BOARDS_LAYOUT = Vector2i(1,1)
		1:
			BOARDS_LAYOUT = Vector2i(1,1)
		2:
			BOARDS_LAYOUT =  Vector2i(2,1)
		3:
			BOARDS_LAYOUT =  Vector2i(2,2)
		4:
			BOARDS_LAYOUT =  Vector2i(2,2)
		_:
			# Get the minimal number of tiles in a rectangular format
			for i in range(floor(sqrt(num_players)),0,-1):
				if num_players % i == 0:
					BOARDS_LAYOUT =  Vector2i(i, num_players / i)
					break;
	PlayerManager.forEachPlayer(default_assign_board_to_player)
	return BOARDS_LAYOUT


func default_assign_board_to_player(player : PlayerInfo) -> void:
	player_native_boards.get_or_add(player.pid, [curr_player_board])
	player_interactable_boards.get_or_add(player.pid, [curr_player_board])
	used_boards.append(curr_player_board)
	
	if curr_player_board.x > BOARDS_LAYOUT.x:
		curr_player_board.y += 1
		curr_player_board.x = 1
	else:
		curr_player_board.x += 1
	
func set_sabo_interactable() -> void:
	for player in player_interactable_boards.keys():
		player_interactable_boards.set(player, used_boards)

func reset_interactable() -> void:
	player_interactable_boards = player_native_boards
	
func set_ui_interactable() -> void:
	for pi in player_interactable_boards.keys():
		_set_interactable_func.call(pi, player_interactable_boards[pi])	
			
