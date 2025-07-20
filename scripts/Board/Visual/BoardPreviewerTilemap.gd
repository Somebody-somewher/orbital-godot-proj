extends BoardPreviewerTileMapAbstract
class_name BoardPreviewerTileMap
# Preview for Highlighting for scoring, AOE and ghost imaging

var tile_score_previewer : BoardTileScorePreviewer

var interactability_check : Callable

func _ready() -> void:
	super._ready()

func set_up(parent : Node, border_dim : Vector2i, playable_area_coords : Array[Vector2i], interactability_check : Callable):
	super._set_up(parent, border_dim)
	self.interactability_check = interactability_check
		
	# For tile scoring labels
	tile_score_previewer = BoardTileScorePreviewer.new(parent,\
		 get_local_centre_of_tile, matrix_to_tilepos(playable_area_coords[0]), matrix_to_tilepos(playable_area_coords[1]))
	
# There might be a scenario where affected_tiles is changed before we can reset_preview
# If that's the case, just do a full reset?
func reset_preview() -> void:
	tile_score_previewer.reset_display()
	super.reset_preview()
	

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
func preview_placement(placeableinstance_id : String, tile_pos : Vector2i = NULL_TILE) -> void:
	if tile_pos == NULL_TILE:
		tile_pos = get_mouse_tile_pos()
		
	var placeable_instance : PlaceableInstanceData = CardLoader.card_mem.local_search_hand_for(placeableinstance_id)
	if placeable_instance:
		interactability_check.call(tile_pos, func():
			if CardLoader.event_manager.check_place_conditions(placeable_instance, tilemap_to_matrix(tile_pos)):
				CardLoader.event_manager.preview_event(placeable_instance, _set_preview, tilemap_to_matrix(tile_pos));\
				place_ghost(placeable_instance.get_data(), tile_pos);\
				return true
			return false
			)
