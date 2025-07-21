extends BoardTileMapLayer
class_name BoardStaticTileMap
# Rock layer for islands


func _ready() -> void:
	super._ready()
	position = Vector2(0, TILE_SIZE/4)

func set_up(parent : Node2D, border_dim : Vector2i, playable_area_coords : Array[Vector2i]) -> void:
	pass
	#viewable_area_coords = [matrix_to_tilepos(playable_area_coords[0]) * TILE_SIZE,\
		 #matrix_to_tilepos(playable_area_coords[1]) * TILE_SIZE]
	
	
func change_terrain_tile(tile_pos : Vector2i) -> void:
	var tile = Vector2i(1,0)
	if tile_pos.x == 0:
		if tile_pos.y == 9:
			tile += Vector2i(0,2)
		if tile_pos.y == 0:
			tile += Vector2i(0,4)
	if tile_pos.x == 9:
		if tile_pos.y == 9:
			tile += Vector2i(0,3)
		if tile_pos.y == 0:
			tile += Vector2i(0,5)
	set_cell(tile_pos, 0, tile, 0)

func change_border_terrain_tile(tile_pos : Vector2i) -> void:
	var tile = Vector2i(1,0)
	if tile_pos.y == 9:
		if tile_pos.x == 9:
			tile += Vector2i(0,3)
		if tile_pos.x == 0:
			tile += Vector2i(0,2)
	set_cell(tile_pos, 0, tile, 5)
