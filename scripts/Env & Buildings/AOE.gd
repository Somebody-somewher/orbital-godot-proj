extends Resource
class_name AOE
# Array of tile positions relative to the building being placed
@export var aoe_tile_positions : Array[Vector2i]
func get_scored_tiles(tile_pos : Vector2i) -> Array[Array]:
	# Get Tile Data of each tile
	
	var board_tile_positions_data : Array[Array] = [[],[]]
	Signalbus.get_tile_pos_from_AOE.emit(tile_pos, aoe_tile_positions, board_tile_positions_data)
	
	# Returns [[tile_pos], [tile_data]]
	return board_tile_positions_data
