extends BoardTileMapLayer
class_name BoardPreviewerTileMap

var tile_score_previewer : BoardTileScorePreviewer

@export var ghost_image : Sprite2D
# Hopefully array will not be overwritten before visual reset
var preview_highlight_tiles : Array[Vector2i]

func _init(parent : Node2D,  get_global : Callable, board_size : int):
	tile_score_previewer = BoardTileScorePreviewer.new(parent, get_global, board_size)

# There might be a scenario where affected_tiles is changed before we can reset_preview
# If that's the case, just do a full reset?
func reset_preview() -> void:
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
		
	preview_highlight_tiles = tiles_to_preview
	
	# If there are scoring tiles, show the score display 
	if !tile_scoring.is_empty():
		tile_score_previewer.display_tile_scores(tiles_to_preview, tile_scoring)
	
	for highlight_tile_pos in preview_highlight_tiles:
		highlight_tile(highlight_tile_pos, true)
	 
func set_preview(board: Board, placeable : PlaceableNode, tile_pos : Vector2i) -> void:
	placeable.data.preview(board, _set_preview, tile_pos)
	
func place_ghost(placeable_data : PlaceableData, tile_pos : Vector2i) -> void:
	get_node("GhostPlaceable").visible = true
	get_node("GhostPlaceable").global_position = local_to_map(tile_pos)
		#board_ref.preview_placement(card_dragged.building, tile_pos_i)
	
