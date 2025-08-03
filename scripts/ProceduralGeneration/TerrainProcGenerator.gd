extends NoiseMapGeneratorAbstract
class_name TerrainGenerator

## Values should be sorted in ascending order otherwise noise check die
#@export var terrain_noise_threshold : Array[float]
#@export var terrains : Array[EnvTerrain]

@export var post_processors : Array = [ProcGenPostProcessTerrainInterface]

# Fills the Matrix with Terrains
func make_matrix() -> Array:
	# ERROR HANDLING
	assert(_items.size() != 0 && noise_threshold.size() != 0)
	assert(_items.size() >= noise_threshold.size())
	if _items.size() > noise_threshold.size():
		printerr("Some Terrain tiles will not be generated")
	
	var matrix = Array()
	matrix.resize(_gen_size.y);
	for y in range(_gen_size.y):
		matrix[y] = Array()
		matrix[y].resize(_gen_size.x)
		
		for x in range(_gen_size.x):
			matrix[y][x] = map_noise_to_terrain(noise_highlight_texture.noise.get_noise_2d(x,y))
			cache.get_or_add(matrix[y][x], []).append(Vector2i(x,y))
			
	return matrix

func post_process(procgen_iterator : ProcGenBoardIterator) -> void:
	print(post_processors)
	for p in post_processors:
		p.process_terrain(procgen_iterator)

func map_noise_to_terrain(noise_val : float) -> EnvTerrain:
	var i = 0;
	# Noise Range tends to be frm -0.6 - 0.7 for Simplex
	# Mapping each cell to terrain-data based off noisemap
	for level in noise_threshold:
		if noise_val <= level:
			return _items[i]
		i += 1
			
	printerr("ProcGen cannot map noise to Terrain ID, noise_val:", noise_val)
	return _items[0] 
