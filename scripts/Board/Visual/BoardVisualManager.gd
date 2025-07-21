extends BoardTileMapLayer
class_name BoardVisualManager

var fake_building_colouration : Color

var placeables_placed : Dictionary[Vector2i, Dictionary]

# Due to my bad coding there are two layers of shading. One for non-interactive tiles, one for the border
# This is a tilemap specifically to darken non-interactive tiles
@export var darken_tilemap : TileMapLayer

var border_coords: Array[Vector2]

# local start-end tilepos of playable area for camera
var viewable_area_coords : Array[Vector2]

func _ready() -> void:
	# Update the positioning of the tilemaps
	super._ready()
	darken_tilemap.scale = Vector2(BOARD_SCALE, BOARD_SCALE)
	darken_tilemap.tile_set = env_map.tileset
	fake_building_colouration = Color.DIM_GRAY
	
	z_index = -1

func set_up(parent : Node2D, border_dim : Vector2i, playable_area_coords : Array[Vector2i]) -> void:
	super._set_up(parent, border_dim)
	border_coords = [playable_area_coords[0], playable_area_coords[1] + Vector2i(2,2)]
	shade_area(playable_area_coords[0], playable_area_coords[1])
	viewable_area_coords = [matrix_to_tilepos(playable_area_coords[0]) * TILE_SIZE,\
		matrix_to_tilepos(playable_area_coords[1]) * TILE_SIZE]

func create_terrain_tile(terrain_id : String, tile_pos : Vector2i) -> void:
	change_terrain_tile(terrain_id, tile_pos)
	darken_tilemap.set_cell(tile_pos, 1, Vector2(0,0), 0)

func change_terrain_tile(terrain_id : String, tile_pos : Vector2i) -> void:
	var darken_tile = 0
	
	# Every alternate tile, set the alternate colour in the tilemap
	if (tile_pos.x + tile_pos.y) % 2 == 1:
		darken_tile += 1
	
	var tile = env_map.getTilePosbyEnv(terrain_id)
	
	set_cell(tile_pos, 0, tile, darken_tile)

func change_border_terrain_tile(terrain_id : String, tile_pos : Vector2i) -> void:
	var darken_tile = 4
	
	# Every alternate tile, set the alternate colour in the tilemap
	if (tile_pos.x + tile_pos.y) % 2 == 1:
		darken_tile += 1
	
	var tile = env_map.getTilePosbyEnv(terrain_id)
	
	print(viewable_area_coords)
	if tile_pos.x == border_coords[0].x:
		if tile_pos.y == border_coords[1].y:
			tile += Vector2i(0,2)
		if tile_pos.y == border_coords[0].y:
			tile += Vector2i(0,4)
	if tile_pos.x == border_coords[1].x:
		if tile_pos.y == border_coords[1].y:
			tile += Vector2i(0,3)
		if tile_pos.y == border_coords[0].y:
			tile += Vector2i(0,5)
	
	set_cell(tile_pos, 0, tile, darken_tile)

# try to place placeable on tile
# Private function
func place_building_on_tile(building: Building, tile_pos : Vector2i) -> void:
	if building != null:
		object.add_child(building)
		building.z_index = tile_pos.y
		building.position = get_local_centre_of_tile(tile_pos)
		building.get_node("JiggleAnimation").play("jiggle")
		
		if !placeables_placed.has(tile_pos):
			placeables_placed[tile_pos] = {building.name : building}
		else:
			placeables_placed[tile_pos][building.name] = building
	# MUST TRIGGER BEFORE ADDING (otherwise places self on board then can score against itself)
	#board_matrix.add_placeable_to_tile(tile_pos, placeable)

func destroy_placeable_image(placeableinstance_id : String, tile_pos : Vector2i) -> void:
	var placeable_to_destroy : PlaceableNode = placeables_placed[tile_pos][placeableinstance_id]
	placeables_placed[tile_pos].erase(placeableinstance_id)
	placeable_to_destroy.destroy()
	
	if placeables_placed[tile_pos].is_empty():
		placeables_placed.erase(tile_pos)

@rpc("any_peer", "call_local")
func place_fake_building(building_id: String, tile_pos : Vector2i) -> void:
	var data : BuildingData = CardLoader.get_building_data(building_id)
	var fake_placeable : Sprite2D = Sprite2D.new()
	fake_placeable.set_texture(data.card_sprite)
	fake_placeable.set_modulate(fake_building_colouration)
	object.add_child(fake_placeable)
	fake_placeable.z_index = tile_pos.y
	fake_placeable.position = get_local_centre_of_tile(tile_pos)

func unshade_area(start_coords : Vector2i, end_coords : Vector2i) -> void:
	start_coords = matrix_to_tilepos(start_coords)
	end_coords = matrix_to_tilepos(end_coords)
	for x in range(start_coords.x, end_coords.x + 1):
		for y in range(start_coords.y, end_coords.y + 1):
			darken_tilemap.erase_cell(Vector2i(x,y))

func shade_area(start_coords : Vector2i, end_coords : Vector2i) -> void:
	start_coords = matrix_to_tilepos(start_coords)
	end_coords = matrix_to_tilepos(end_coords)
	for x in range(start_coords.x, end_coords.x + 1):
		for y in range(start_coords.y, end_coords.y + 1):
			darken_tilemap.set_cell(Vector2i(x,y), 1, Vector2(0,0), 0)
