extends NoiseMapGeneratorAbstract
class_name BuildingProcGenerator

# Values should be sorted in ascending order otherwise noise check die
@export var building_noise_threshold : Array[float]
@export var env_buildings : Array[BuildingData]
var _terrain_iterator

@export var post_processors : Array[ProcGenPostProcessBuildingInterface]

var buildings_placed : Dictionary[BuildingData, Array]

# No function overload :<
func set_up_terrain(terrain_iterator : ProcGenBoardIterator) -> void:
	_terrain_iterator = terrain_iterator

func make_matrix() -> Array:
	assert(env_buildings.size() >= building_noise_threshold.size())
	if env_buildings.size() > building_noise_threshold.size():
		printerr("Some Buildings tiles will not be generated")
	
	var matrix = Array()
	matrix.resize(_gen_size.x);
	for x in range(_gen_size.x):
		matrix[x] = Array()
		matrix[x].resize(_gen_size.y)
		
		for y in range(_gen_size.y):
			matrix[x][y] = map_noise_to_building(noise_highlight_texture.noise.get_noise_2d(x,y), _terrain_iterator.retrieve_matrix()[x][y])
			buildings_placed.get_or_add(matrix[x][y], []).append(Vector2i(x,y))
			
	return matrix

func post_process(procgen_iterator : ProcGenBoardIterator) -> void:
	for p in post_processors:
		p.process(procgen_iterator, _terrain_iterator)

func map_noise_to_building(noise_val : float, terrain : EnvTerrain) -> BuildingData:
	var i = 0;
	for level in building_noise_threshold:
		if noise_val <= level:
			if terrain not in env_buildings[i].nonplaceable_terrain:
				return env_buildings[i]
		i += 1
			
	return null
	
