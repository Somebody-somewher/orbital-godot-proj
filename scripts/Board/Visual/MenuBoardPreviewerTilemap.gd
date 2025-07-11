extends BoardPreviewerTileMapAbstract
class_name MenuBoardPreviewerTileMap
## Board Class Previewer stripped to its most basic features
## Mainly for use by the Menu Board class
## Preview for Highlighting for scoring, AOE and ghost imaging

func _ready() -> void:
	_border_dim = Vector2i(0,0)
	super._ready()

## Called by card_manager and displays the ghost image
func preview_placement(placeableinstance_id : String, tile_pos : Vector2i = NULL_TILE) -> void:
	if tile_pos == NULL_TILE:
		tile_pos = get_mouse_tile_pos()
		
	var placeable_instance : PlaceableData = CardLoader.get_building_data(placeableinstance_id)
	if placeable_instance:
		place_ghost(placeable_instance.get_data(), tile_pos);
		set_cell(tile_pos, true)
