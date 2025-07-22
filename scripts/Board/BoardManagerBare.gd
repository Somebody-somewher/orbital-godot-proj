extends Node2D
class_name BoardManagerBare
## Board Class stripped to its most basic features
## Mainly for use by the Menu Board class

####################### KEY DEFINING BOARD VARS ##########################
######### ALL TO BE STANDARDIZED BY SERVER BOARDMANAGER INSTANCE #########
# Length/Width (no. cells) of board
# TODO: PLEASE KEEP THE BOARD SQUARE FOR NOW
@export var BOARD_SIZE : Vector2i = Vector2i(8,8)
@export var BOARD_SCALE : float
#########################################################################

#@export var terrain_tilemap : BoardVisualManager
#@export var previewer_tilemap : BoardPreviewerTileMap

@export var terrain_tilemap : BoardVisualManager
@export var under_tilemap : BoardTileMapLayer
@export var previewer_tilemap : BoardPreviewerTileMapAbstract
@export var env_map : EnvTerrainMapping
@export var object : Node

var temp_building_instance : PlaceableInstanceData

var board_coords : Array[Vector2i]
# reference for non-existent tile position
static var NULL_TILE = Vector2i(-1,-1)

# For the hover_over_tile signal
var _prev_tile_pos : Vector2i = Vector2i(-1,-1)

func _ready() -> void:
	var placeholder_id = terrain_tilemap.env_map.getPlaceholderTile().get_id()
	for x in range(BOARD_SIZE.x):
		for y in range(BOARD_SIZE.y):
			create_terrain.call(placeholder_id, Vector2i(x,y))
	board_coords = [Vector2i(0,0), BOARD_SIZE - Vector2i(1,1)]
	set_up()

## Called when the node enters the scene tree for the first time.
func set_up() -> void:	
		# Tilemaps setup
		terrain_tilemap.set_up(object, Vector2i(0,0), board_coords)
		previewer_tilemap.set_up(object, Vector2i(0,0), board_coords, func(tilepos : Vector2i, c : Callable):
			if check_tilepos_in_playable(tilepos):
				c.call() 
			)
		set_interactable_board([])


## Actual chec whether the mouse is near board
func is_pos_near_board(mouse_pos : Vector2i) -> bool:
	# Roughly one cell away
	var THRESHOLD = 1.5 * terrain_tilemap.TILE_SIZE
	var start_pos : Vector2i = terrain_tilemap.get_local_centre_of_tile(terrain_tilemap.matrix_to_tilepos(board_coords[0]))
	var end_pos : Vector2i = terrain_tilemap.get_local_centre_of_tile(terrain_tilemap.matrix_to_tilepos(board_coords[1]))
	if mouse_pos.x > start_pos.x - THRESHOLD and mouse_pos.x < end_pos.x + THRESHOLD:
			return mouse_pos.y > start_pos.y - THRESHOLD and mouse_pos.y < end_pos.y + THRESHOLD
	return false


func _process(delta: float) -> void:
		
	# Checks whether the mouse is hovering over a new interactable tile, sends a signal out if so
	# Impt for card_manager to show indicator that the card can be placed on the board
	var curr_tile_pos : Vector2i = get_mouse_tile_pos() 
	if curr_tile_pos != _prev_tile_pos: #and matrix_data.get_boardcoords_of_tilepos(terrain_tilemap.tilemap_to_matrix(curr_tile_pos)) != []:
		Signalbus.emit_signal("mouse_enter_interactable_board_tile")
		_prev_tile_pos = curr_tile_pos
	
	pass
## Check if tilepos inside playable area
func check_tilepos_in_playable(tilepos : Vector2i) -> bool:
	if tilepos.x >=  board_coords[0].x and tilepos.x <= board_coords[1].x:
		if tilepos.y >= board_coords[0].y and tilepos.y <= board_coords[1].y:
			return true
	return false

## Get the tilepos of mouse
func get_mouse_tile_pos() -> Vector2i:
	var tile_mouse_pos = terrain_tilemap.get_mouse_tile_pos()
	if check_tilepos_in_playable(terrain_tilemap.tilemap_to_matrix(tile_mouse_pos)):
		return tile_mouse_pos
	else:
		return NULL_TILE

## Client drags card to board, function calls server to request validation
func place_cardplaceable(placeable_id : String, tile_pos : Vector2i = NULL_TILE) -> void:
	if tile_pos == NULL_TILE:
		tile_pos = get_mouse_tile_pos()
	
	if tile_pos != NULL_TILE:
		terrain_tilemap.place_building_on_tile(Building.new_building(placeable_id), tile_pos)
		Signalbus.emit_signal("board_action_result", true)
	else:
		Signalbus.emit_signal("board_action_result", false)

func clear_tile(placeableinstance_id : String, tile_pos : Vector2i) -> void:
	terrain_tilemap.destroy_placeable_image(placeableinstance_id, tile_pos)

## Shade and unshade the individual boards that are interactable
@rpc("any_peer","call_local")
func set_interactable_board(boards: Array) -> void:
	terrain_tilemap.unshade_area(board_coords[0], board_coords[1])

@rpc("any_peer","call_local")
func create_terrain(terrain_id : String, tile_pos : Vector2i) -> void:
	if tile_pos == NULL_TILE:
		tile_pos = get_mouse_tile_pos()
	terrain_tilemap.change_terrain_tile(terrain_id, tile_pos)
	
func is_mouse_near_interactable_board() -> bool:
	var mouse_pos = get_local_mouse_position()
	return is_pos_near_board(mouse_pos)
