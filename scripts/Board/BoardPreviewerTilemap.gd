extends BoardTileMapLayer
class_name BoardPreviewerTileMap
# Preview for Highlighting for scoring, AOE and ghost imaging

var tile_score_previewer : BoardTileScorePreviewer

@export var ghost_image : Sprite2D

# Hopefully array will not be overwritten before visual reset
var preview_highlight_tiles : Array[Vector2i]
var _check_in_playable_area : Callable

# local start-end tilepos of playable area for camera
var viewable_area_coords : Array[Vector2]
# To get the playable area
var _matrix : BoardMatrixData

func _ready() -> void:
	super._ready()
	ghost_image.scale = Vector2(1.0/BOARD_SCALE, 1.0/BOARD_SCALE)

func set_up(parent : Node, matrix : BoardMatrixData, border_dim : Vector2i):
	super._set_up(parent, border_dim)
	_matrix = matrix
	
	# Coordinates setup for camera
	var coords : Array[Vector2i] = matrix.get_playable_area_coords()
	viewable_area_coords = [matrix_to_tilepos(coords[0]) * TILE_SIZE, matrix_to_tilepos(coords[1]) * TILE_SIZE]
	
	# For tile scoring labels
	tile_score_previewer = BoardTileScorePreviewer.new(parent, get_local_centre_of_tile, matrix_to_tilepos(coords[0]), matrix_to_tilepos(coords[1]))
	
# There might be a scenario where affected_tiles is changed before we can reset_preview
# If that's the case, just do a full reset?
func reset_preview() -> void:
	ghost_image.visible = false
	tile_score_previewer.reset_display()
	for tile_pos in preview_highlight_tiles:
		highlight_tile(tile_pos, false)
		
func highlight_tile(coord : Vector2i, on : bool) -> void:
	if on:
		set_cell(coord,2, Vector2i(0,0),0)
	else:
		set_cell(coord, -1, Vector2i(0,0), 0)
		
		#get_tile(coord).off_score_display()

## Called by score event by it being sent as a Callable param
## in charge of displaying scoring tiles
func _set_preview(tiles_to_preview : Array[Vector2i], tile_scoring : Array[int] = []) -> void:
	reset_preview()
	# If there are no tiles to highlight return
	if tiles_to_preview.is_empty():
		return;
	
	preview_highlight_tiles = tiles_to_preview.duplicate(true)
	for i in len(preview_highlight_tiles):
		preview_highlight_tiles[i] = matrix_to_tilepos(preview_highlight_tiles[i])
		highlight_tile(preview_highlight_tiles[i], true)
		
	# If there are scoring tiles, show the score display 
	if !tile_scoring.is_empty():
		tile_score_previewer.display_tile_scores(preview_highlight_tiles, tile_scoring)	

## Called by card_manager and displays the ghost image
func preview_placement(placeable : PlaceableData, tile_pos : Vector2i = NULL_TILE) -> void:
	if tile_pos == NULL_TILE:
		tile_pos = get_mouse_tile_pos()
	
	if _matrix.check_tilepos_in_playable(tilemap_to_matrix(tile_pos)) and placeable.placeable(_matrix, tilemap_to_matrix(tile_pos)):
		# Sends the _set_preview to the placeable scorer event
		placeable.preview(_matrix, _set_preview, tilemap_to_matrix(tile_pos))
		place_ghost(placeable, tile_pos)

func place_ghost(placeable_data : PlaceableData, tile_pos : Vector2i) -> void:
	ghost_image.texture = placeable_data.card_sprite
	ghost_image.visible = true
	ghost_image.global_position = get_local_centre_of_tile(tile_pos)	

func get_board_coords() -> Array[Vector2]:
	return viewable_area_coords
