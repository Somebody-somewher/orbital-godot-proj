extends BoardPreviewerTileMapAbstract
class_name MenuBoardPreviewerTileMap
## Board Class Previewer stripped to its most basic features
## Mainly for use by the Menu Board class
## Preview for Highlighting for scoring, AOE and ghost imaging

var interactability_check : Callable

func set_up(parent : Node, border_dim : Vector2i, playable_area_coords : Array[Vector2i], interactability_check : Callable):
	super._set_up(parent, border_dim)
	self.interactability_check = interactability_check

func _ready() -> void:
	_border_dim = Vector2i(0,0)
	super._ready()

## Called by card_manager and displays the ghost image
func preview_placement(placeableinstance_id : String, tile_pos : Vector2i = NULL_TILE) -> void:
	reset_preview()
	if tile_pos == NULL_TILE:
		tile_pos = get_mouse_tile_pos()
		
	var placeable_instance : PlaceableData = CardLoader.get_building_data(placeableinstance_id)
	
	interactability_check.call(tile_pos, func():
		if placeable_instance:
			place_ghost(placeable_instance, tile_pos);\
			highlight_tile(tile_pos, true);\
			preview_highlight_tiles.append(tile_pos)
			return true
		return false
			)
	
