extends BoardTileMapLayer
class_name BoardPreviewerTileMapAbstract
# Preview for Highlighting for scoring, AOE and ghost imaging

@export var ghost_image : Sprite2D

# Hopefully array will not be overwritten before visual reset
var preview_highlight_tiles : Array[Vector2i]

func _ready() -> void:
	super._ready()
	#ghost_image.scale = Vector2(1.0/BOARD_SCALE, 1.0/BOARD_SCALE)	

# There might be a scenario where affected_tiles is changed before we can reset_preview
# If that's the case, just do a full reset?
func reset_preview() -> void:
	ghost_image.visible = false
	for tile_pos in preview_highlight_tiles:
		highlight_tile(tile_pos, false)
		
func highlight_tile(coord : Vector2i, on : bool) -> void:
	if on:
		set_cell(coord,2, Vector2i(0,0),0)
	else:
		set_cell(coord, -1, Vector2i(0,0), 0)
		#get_tile(coord).off_score_display()

## Called by card_manager and displays the ghost image
func preview_placement(placeableinstance_id : String, tile_pos : Vector2i = NULL_TILE) -> void:
	pass

func place_ghost(placeable_data : PlaceableData, tile_pos : Vector2i) -> void:
	ghost_image.texture = placeable_data.card_sprite
	ghost_image.visible = true
	ghost_image.position = get_local_centre_of_tile(tile_pos)
