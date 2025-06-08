extends BoardTileMapLayer
class_name BoardPreviewerTileMap

var tile_score_previewer : BoardTileScorePreviewer

@export var ghost_image : Sprite2D

# Hopefully array will not be overwritten before visual reset
var preview_highlight_tiles : Array[Vector2i]
var _check_in_playable_area : Callable

var _border_dim : Vector2i

#TODO :<
var _matrix

func _ready() -> void:
	super._ready()
	ghost_image.scale = Vector2(1.0/BOARD_SCALE, 1.0/BOARD_SCALE)

func set_up(parent : Node, playable_size : int, check_in_playable_area : Callable, border_dim : Vector2i):
	_check_in_playable_area = check_in_playable_area
	_border_dim = border_dim
	tile_score_previewer = BoardTileScorePreviewer.new(parent, get_local_centre_of_tile, playable_size, border_dim)

#TODO :<
func get_board_data(matrix : BoardMatrixData) -> void:
	_matrix = matrix
	
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
		
func _set_preview(tiles_to_preview : Array[Vector2i], tile_scoring : Array[int] = []) -> void:
	reset_preview()
	# If there are no tiles to highlight return
	if tiles_to_preview.is_empty():
		return;
	
	preview_highlight_tiles = tiles_to_preview.duplicate(true)
	for i in len(preview_highlight_tiles):
		preview_highlight_tiles[i] = preview_highlight_tiles[i] + _border_dim
		highlight_tile(preview_highlight_tiles[i], true)
		
	# If there are scoring tiles, show the score display 
	if !tile_scoring.is_empty():
		tile_score_previewer.display_tile_scores(preview_highlight_tiles, tile_scoring)	

func preview_placement(placeable : PlaceableData, tile_pos : Vector2i = NULL_TILE) -> void:
	if tile_pos == NULL_TILE:
		tile_pos = get_mouse_tile_pos()
		
	if _check_in_playable_area.call(tile_pos - _border_dim):
		placeable.preview(_matrix, _set_preview, tile_pos - _border_dim)
		place_ghost(placeable, tile_pos)

func place_ghost(placeable_data : PlaceableData, tile_pos : Vector2i) -> void:
	# TODO: PAIN
	if placeable_data.placeable(_matrix, tile_pos):
		if placeable_data is BuildingData:
			
			# TODO: Check if building is placeable is stackable, if so then show the image
			
			ghost_image.texture = (placeable_data as BuildingData).building_sprite
			ghost_image.visible = true
	
	ghost_image.global_position = get_local_centre_of_tile(tile_pos)
	
		#board_ref.preview_placement(card_dragged.building, tile_pos_i)
	
