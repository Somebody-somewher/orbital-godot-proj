extends Object
class_name BoardLayout


var BOARDS_LAYOUT : Vector2i

# UserID -> Array of BoardIds
# the board ids are the boards this player controls during build phase
var player_native_boards : Dictionary[String, Array]

# UserID -> Array of BoardIds
# the board ids represent the boards that the player can interact with
var player_sabo_boards : Dictionary[String, Array]

var player_interactable_boards : Dictionary[String, Array]

# Boards currently in use by players
var used_boards : Array

var _set_interactable_func : Callable

var starting_player_board : Vector2i = Vector2i(1,1)
var curr_player_board : Vector2i = starting_player_board

func _init(set_interactable_func : Callable) -> void:
	_set_interactable_func = set_interactable_func
	Signalbus.set_interactable_board_state.connect(set_interactable)
	
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
	player_native_boards.get_or_add(player.getPlayerUUID(), [curr_player_board])
	#player_interactable_boards.get_or_add(player.getPlayerUUID(), [curr_player_board])
	used_boards.append(curr_player_board)
	player_sabo_boards.set(player.getPlayerUUID(), used_boards)
	
	if curr_player_board.x >= BOARDS_LAYOUT.x:
		curr_player_board.y += 1
		curr_player_board.x = 1
	else:
		curr_player_board.x += 1
	
func set_interactable(state_id : String) -> void:
	if state_id == "sabo":
		player_interactable_boards.assign(player_sabo_boards)
	else:
		player_interactable_boards.assign(player_native_boards)
	
	set_layout_interactable()

func set_layout_interactable() -> void:
	for player_uuid in player_interactable_boards.keys():
		_set_interactable_func.call(\
			PlayerManager.getPeerID_from_UUID(player_uuid), \
				player_interactable_boards[player_uuid], used_boards)	

func reset() -> void:
	Signalbus.set_interactable_board_state.disconnect(set_interactable)
