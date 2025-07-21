extends BoardTileMapLayer
class_name BoardStaticTileMap
# Rock layer for islands

var border_coords : Array[Vector2i]

func _ready() -> void:
	super._ready()
	position = Vector2(0, TILE_SIZE/4)

func set_up(parent : Node2D, border_dim : Vector2i, playable_area_coords : Array[Vector2i]) -> void:
	border_coords = [playable_area_coords[0], playable_area_coords[1] + Vector2i(2,2)]
	pass
	#viewable_area_coords = [matrix_to_tilepos(playable_area_coords[0]) * TILE_SIZE,\
		 #matrix_to_tilepos(playable_area_coords[1]) * TILE_SIZE]
	
	
func change_terrain_tile(tile_pos : Vector2i) -> void:
	var tile = Vector2i(1,0)
	if tile_pos.y == border_coords[1].y:
		if tile_pos.x == border_coords[1].x:
			tile += Vector2i(0,3)
		if tile_pos.x == border_coords[0].x:
			tile += Vector2i(0,2)
	set_cell(tile_pos, 0, tile, 0)

func change_border_terrain_tile(tile_pos : Vector2i) -> void:
	var tile = Vector2i(1,0)
	if tile_pos.y == border_coords[1].y:
		if tile_pos.x == border_coords[1].x:
			tile += Vector2i(0,3)
		if tile_pos.x == border_coords[0].x:
			tile += Vector2i(0,2)
	set_cell(tile_pos, 0, tile, 5)
