extends Node2D

@export var BOARD_SIZE : int = 8
@export var NUM_OF_BOARDS : int = 4
@export var gap_btwn_board : int = 10

@export var display_noise: TextureRect 


@export
var board : PackedScene = preload("res://scenes/Board/board.tscn")

func _ready() -> void:
	create_boards()

# Create multiple boards in matrix formation for display
# Or multiple players
func create_boards() -> void:
	proc_generator.set_up()
	
	if display_noise != null:
		display_noise.set_texture(proc_generator.noise_highlight_texture)
	
	var length = ceil(sqrt(NUM_OF_BOARDS))
	var count_id = 0
	var create_pos : Vector2i = Vector2(0,0)
	var board_inst : Board
	var board_global_len : int 
	for row in range(length):
		for col in range(length):
			if count_id >= NUM_OF_BOARDS:
				return
			board_inst = board.instantiate()
			
			board_inst.board_id = count_id
			board_inst.BOARD_SIZE = BOARD_SIZE
			#board_inst.proc_gen = proc_generator
			
			add_child(board_inst)
			board_global_len = board_inst.get_global_length()
			
			board_inst.position = Vector2i(col * (board_global_len + gap_btwn_board), row * (board_global_len + gap_btwn_board))

			# Assigning variables to Board
			count_id += 1
