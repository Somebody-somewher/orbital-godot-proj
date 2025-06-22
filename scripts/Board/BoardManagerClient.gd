extends BoardManagerBase
class_name BoardManagerClient
# Main class that handles all "board" functionality. 
# Technically the "board" is made up of smaller "sub"-boards where each "sub"-board belongs to a player

var player_board_ids : Array[int] 

# Called when the node enters the scene tree for the first time.
func set_up() -> void:	
	super.set_up()

## Params supplied by server, called by all clients
@rpc("any_peer", "call_local")
func receive_init_data(board_size : Vector2i, board_layout : Vector2i, border_dim : Vector2i) -> void:
	BOARD_SIZE = board_size
	BOARDS_LAYOUT = board_layout
	BORDER_DIM = border_dim
	set_up()
	pass

func _ready() -> void:
	super._ready()
	NetworkManager.mark_client_ready(self.name)	

## Create a buildindg on a givne tilepos, data + visual
func _place_placeable(placeable_instance: PlaceableInstanceData, tile_pos : Vector2i) -> PlaceableNode:
	var placeable_node : PlaceableNode = super._place_placeable(placeable_instance, tile_pos)
	terrain_tilemap.place_building_on_tile(placeable_node, tile_pos)
	return placeable_node

## Shade and unshade the individual boards that are interactable
@rpc("any_peer","call_local")
func set_interactable_board(boards: Array) -> void:
	var board_coords 
	for b in boards:
		board_coords = matrix_data.set_board_interactable(b)
		terrain_tilemap.unshade_area(board_coords[0] \
			, board_coords[1])
		
@rpc("any_peer", "call_local")
func remove_building(tile_pos : Vector2i = NULL_TILE) -> void:
	pass

func tilemap_to_matrix(tilemap_pos : Vector2i) -> Vector2i:
	return tilemap_pos - BORDER_DIM 

func matrix_to_tilepos(matrix_pos : Vector2i) -> Vector2i:
	return BORDER_DIM + matrix_pos
