# Procedural Generator, given a grid size, generates a 2d matrix
# with each cell containing a terrain id.
extends Resource
class_name ProceduralGenerator

# size of the expected grid
@export var board_size : Vector2i 
@export var num_board: int

# Actually noise map to generate the map
@export var noise_highlight_texture : NoiseTexture2D
var noise : Noise

# Pair of noise_value -> terrain, noise vals should be between -0.6 to 0.69  for Simplex Smooth
# Values should be sorted in ascending order otherwise noise check die
@export var noise_threshold : Array[float]
@export var terrain_ids : Array[String]

# This is only called if ProceduralGenerator is create by 
func _init(size):
	noise_highlight_texture = generateNoiseTexture()

func create_matrix() -> Array[Array]:
	var matrix = Array()
	var width = board_size.x
	var height = board_size.y
		
	matrix.resize(width);
	for i in range(width):
		matrix[i] = Array()
		matrix[i].resize(height)
	return matrix

func generateNoiseTexture(seed : int = -1) -> NoiseTexture2D:
	# Noise Source
	var noise = FastNoiseLite.new()
	if seed == -1:
		noise.seed = randi()
	else:
		noise.seed = seed
	
	# Noise Texture
	var noise_texture = NoiseTexture2D.new()
	var noise_size_numboard : Vector2i = noiseSizeByNumBoard() 
	noise_texture.set_width(board_size.x * noise_size_numboard.x)
	noise_texture.set_height(board_size.y * noise_size_numboard.y)
	noise_texture.set_noise(noise)
	
	return noise_texture

# Generates a 2d matrix, each cell containing a terrarin resource
# based off the noise map
func generate_world(board_id : int = 0) -> Array:
	
	# ERROR HANDLING
	assert(terrain_ids.size() >= noise_threshold.size())
	if terrain_ids > noise_threshold:
		printerr("Some Terrain tiles will not be generated")
	if board_id > num_board:
		printerr("ProcGen Noise cannot create Terrain for more boards, Remap to used noise")
		board_id = 0
	
	var matrix = create_matrix()
	noise = noise_highlight_texture.noise
	var noise_val : float
	var offset : Vector2i = getOffsetByBoardId(board_id)
	for x in range(board_size.x):
		for y in range(board_size.y):
			noise_val = noise.get_noise_2d(offset.x + x, offset.y + y)
			
			# Mapping each cell to a (pointer to) terrain-data based off noisemap
			matrix[x][y] = map_noise_to_terrain(noise_val)
	
	return matrix

func map_noise_to_terrain(noise_val : float) -> String:
	var i = 0;
	for level in noise_threshold:
		if noise_val <= level:
			return terrain_ids[i]
			
	printerr("ProcGen cannot map noise to Terrain ID")
	return terrain_ids[0] 

# Abstracting these functions away in case we want to change the functionality later
# Creates a square-sized noisemap that minimally covers the number of grids needed
func noiseSizeByNumBoard() -> Vector2:
	var temp = ceil(sqrt(num_board))
	return Vector2i(temp, temp)
	
func getOffsetByBoardId(board_id: int) -> Vector2i:
	var noise_width_bynumboard : int = noiseSizeByNumBoard().x 
	var x : int = board_size.x % noise_width_bynumboard
	var y : int = (board_size.x - x) / noise_width_bynumboard
	return Vector2i(x,y)

#
#func getTerrainAtCell(x : int, y : int):
	#return matrix[x][y]
