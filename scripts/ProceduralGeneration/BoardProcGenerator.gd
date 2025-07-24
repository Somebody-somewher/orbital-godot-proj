extends Resource
class_name BoardProcGenerator

@export var terrain_gen : NoiseMapGeneratorAbstract
@export var building_gen : NoiseMapGeneratorAbstract
@export var env_map : EnvTerrainMapping

@export var terrain_seed : int = -1
@export var building_seed : int = -1

var procgen_building_iter : ProcGenBoardIterator
var procgen_terrain_iter : ProcGenBoardIterator
var has_setup : bool = false

func set_up(board_size : Vector2i = Vector2i(8,8), board_num : Vector2i = Vector2i(1,1), border_width : Vector2i = Vector2i(0,0)) -> void:
	terrain_gen.set_up(board_size, board_num, border_width)
	
	# Debug check
	assert(check_terrain_valid(terrain_gen))
	procgen_terrain_iter = terrain_gen.generate_world() 

	if building_gen != null:
		building_gen.set_up(board_size, board_num, border_width)
		building_gen.set_up_terrain(procgen_terrain_iter)
		procgen_building_iter = building_gen.generate_world()
	
	has_setup = true
	
func generate_board(terrain_create : Callable, board_id : int) -> void:
	if !has_setup:
		set_up()

	procgen_terrain_iter.skip_to_board(board_id)
	procgen_terrain_iter.foreach_tile_in_board(terrain_create)
	
	#if building_gen != null:
		#
		#procgen_building_iter.skip_to_board(board_id)
		#procgen_building_iter.foreach_tile_in_board(building_create)

func generate_actual_buildings(building_create : Callable) -> void:
	building_create.call(procgen_building_iter.cache)
	
func generate_border(terrain_create : Callable, building_create : Callable) -> void:
	if !has_setup:
		set_up()
	
	procgen_terrain_iter.foreach_border(terrain_create)
	procgen_building_iter.foreach_border(building_create)

func check_terrain_valid(terrain_gen : TerrainGenerator) -> bool:
	for t in terrain_gen.terrains:
		if !env_map.checkEnvExists(t.get_id()):
			return false
	return true
	
	func reset() -> void:
	has_setup = false
	terrain_gen.reset()
	building_gen.reset()
