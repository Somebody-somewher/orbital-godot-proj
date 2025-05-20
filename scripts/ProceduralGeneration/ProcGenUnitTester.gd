extends Node2D

@export var NUM_OF_BOARDS : int = 4
@export var gap_btwn_board : int = 10
@export var z : int

@export 
var proc_generator : ProceduralGenerator
@export
var board : PackedScene = preload("res://scenes/Board/board.tscn")

func _ready() -> void:
	create_boards()

# Create multiple boards in matrix formation for display
# Or multiple players
func create_boards() -> void:
	
	#if proc_generator
	
	
	var length = ceil(sqrt(NUM_OF_BOARDS))
	var count = 0
	var create_pos : Vector2i = Vector2(0,0)
	var board_inst : Board
	for x in range(length):
		for y in range(length):
			if count > NUM_OF_BOARDS:
				return
			board_inst = board.instantiate()
			add_child(board_inst)
			z = board_inst.get_global_length()
			board_inst.offset = Vector2i(0,0)
			board_inst.position = Vector2i(x * (z + gap_btwn_board), y * (z + gap_btwn_board))
			count += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
