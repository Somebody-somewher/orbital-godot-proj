extends Resource
class_name AOE
# Array of tile positions relative to the building being placed
@export var aoe_tile_positions : Array[Vector2i]

func get_scored_tiles(board : Board, tile_pos : Vector2i) -> Array[Array]:
	
	# Find the affected tile positions via the board
	# TODO: Technically a cyclic dependency but we can probs change it via a Callable 
	# or make an abstraction to board down the line
	var affected_tiles_pos = board.constrain_pattern_to_board(aoe_tile_positions, tile_pos)
	
	# Get Tile Data of each tile
	var affected_tiles : Array[Array] = [[],[]]
	for i in affected_tiles_pos:
		affected_tiles[0].append(i)
		affected_tiles[1].append(board.get_tile(i))
	return affected_tiles
