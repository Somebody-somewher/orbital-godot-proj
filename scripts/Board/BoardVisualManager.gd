extends BoardTileMapLayer
class_name BoardVisualManager

# Due to my bad coding there are two layers of shading.
# This is a tilemap specifically to darken non-interactive tiles
@export var darken_tilemap : TileMapLayer

func _ready() -> void:
	# Update the positioning of the tilemaps
	super._ready()
	darken_tilemap.scale = Vector2(BOARD_SCALE, BOARD_SCALE)
	darken_tilemap.tile_set = env_map.tileset
	fake_building_colouration = Color.DIM_GRAY
	z_index = -1

func set_up(parent : Node2D, border_dim : Vector2i) -> void:
	super._set_up(parent, border_dim)

func create_terrain_tile(terrain : EnvTerrain, tile_pos : Vector2i) -> void:
	change_terrain_tile(terrain, tile_pos)
	darken_tilemap.set_cell(tile_pos, 1, Vector2(0,0), 0)

func change_terrain_tile(terrain : EnvTerrain, tile_pos : Vector2i) -> void:
	var darken_tile = 0
	
	# Every alternate tile, set the alternate colour in the tilemap
	if (tile_pos.x + tile_pos.y) % 2 == 1:
		darken_tile += 1
	
	set_cell(tile_pos, 0, env_map.getTilePosbyEnv(terrain), darken_tile)

func change_border_terrain_tile(terrain : EnvTerrain, tile_pos : Vector2i) -> void:
	var darken_tile = 4
	
	# Every alternate tile, set the alternate colour in the tilemap
	if (tile_pos.x + tile_pos.y) % 2 == 1:
		darken_tile += 1
	
	set_cell(tile_pos, 0, env_map.getTilePosbyEnv(terrain), darken_tile)

# try to place placeable on tile
# Private function
func place_building_on_tile(data: BuildingData, tile_pos : Vector2i) -> void:
	if data != null:
		var building : Building = Building.new_building_frm_data(data)
		object.add_child(building)
		building.z_index = tile_pos.y
		building.position = get_local_centre_of_tile(tile_pos)
		building.get_node("JiggleAnimation").play("jiggle")
	# MUST TRIGGER BEFORE ADDING (otherwise places self on board then can score against itself)
	#board_matrix.add_placeable_to_tile(tile_pos, placeable)
	
func unshade_area(start_coords : Vector2i, end_coords : Vector2i) -> void:
	for x in range(start_coords.x, end_coords.x + 1):
		for y in range(start_coords.y, end_coords.y + 1):
			darken_tilemap.erase_cell(Vector2i(x,y))

func shade_area(start_coords : Vector2i, end_coords : Vector2i) -> void:
	for x in range(start_coords.x, end_coords.x + 1):
		for y in range(start_coords.y, end_coords.y + 1):
			darken_tilemap.set_cell(Vector2i(x,y), 1, Vector2(0,0), 0)
