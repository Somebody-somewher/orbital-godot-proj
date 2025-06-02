extends Resource
class_name ProceduralGenerator
# Procedural Generator, given a grid size, generates a 2d matrix
# with each cell containing a terrain id.

# size of the expected grid
@export var board_size : Vector2i 
@export var num_board: int

# Actually noise map to generate the map
@export var noise_highlight_texture : NoiseTexture2D
@export var terrain_noise_freq : float =  0.0583

# Values should be sorted in ascending order otherwise noise check die
@export var terrain_noise_threshold : Array[float]
@export var terrain_ids : Array[String]

@export var post_processors : Array[ProcGenPostBase] = []

# Call this to start the proc_gen (can be called multiple times without error)
func set_up() -> void:
	randomize()
	# If noise texture is not provided, we randomize a new one
	if noise_highlight_texture == null:
		noise_highlight_texture = generate_noise_texture(terrain_noise_freq)	

# Create a matrix that is the size of one board
func create_matrix() -> Array:
	var matrix = Array()
	var width = board_size.x
	var height = board_size.y
		
	matrix.resize(width);
	for col in range(width):
		matrix[col] = Array()
		matrix[col].resize(height)
	return matrix

# Creates randomized Noise Texture
func generate_noise_texture(freq : float = 0.0583, noise_seed : int = -1) -> NoiseTexture2D:
	# Noise Source
	var noise = FastNoiseLite.new()
	if noise_seed == -1:
		print("RANDOMIZING TERRAIN")
		noise.seed = randi()
	else:
		noise.seed = seed
	noise.frequency = freq
	# Noise Texture
	var noise_texture = NoiseTexture2D.new()
	var noise_size_numboard : Vector2i = noiseSizeByNumBoard() 
	noise_texture.set_width(board_size.x * noise_size_numboard.x)
	noise_texture.set_height(board_size.y * noise_size_numboard.y)
	noise_texture.set_normalize(true)
	
	# I wanted to try to make this noisemap seamless
	# i.e wrap around, but seems like it no want to cooperate
	# noise_texture.set_seamless(true)
	# noise_texture.set_seamless_blend_skirt(9.0)
	
	noise_texture.set_noise(noise)
	return noise_texture

# Fills the Matrix with Terrain IDs
func make_terrain_matrix(board_id : int = 0) -> Array:
	# ERROR HANDLING
	assert(terrain_ids.size() != 0 && terrain_noise_threshold.size() != 0)
	assert(terrain_ids.size() >= terrain_noise_threshold.size())
	if terrain_ids.size() > terrain_noise_threshold.size():
		printerr("Some Terrain tiles will not be generated")
	if board_id > num_board:
		printerr("ProcGen Noise cannot create Terrain for more boards, Remap to used noise")
		board_id = 0
	
	var matrix = create_matrix()
	var noise = noise_highlight_texture.noise
	var noise_val : float
	var offset : Vector2i = getOffsetByBoardId(board_id) * board_size
	for col in range(board_size.x):
		for row in range(board_size.y):
			noise_val = noise.get_noise_2d(offset.x + col, offset.y + row)
			matrix[col][row] = Array() 
			matrix[col][row].append(map_noise_to_terrain(noise_val))
	return matrix

# Foreach function that takes in the board's tile create functions to generate 
# the board
#
# board_id is for multiple boards, where each other board takes a different 
# square piece of the bigger noisemap
func generate_world(create_tile : Callable, create_build: Callable, board_id : int = 0):
	set_up()
	var matrix = make_terrain_matrix(board_id)
	
	for col in range(board_size.x):
		for row in range(board_size.y):
			create_tile.call(Vector2i(col,row) ,matrix[col][row][0])
	
	assign_buildings(matrix, board_id)
	post_process(matrix, board_size.x, board_size.y)
	add_buildings(matrix, create_build)

	
func map_noise_to_terrain(noise_val : float) -> String:
	var i = 0;
	# Noise Range tends to be frm -0.6 - 0.7 for Simplex
	# print(noise_val)
			
	# Mapping each cell to terrain-data based off noisemap
	for level in terrain_noise_threshold:
		if noise_val <= level:
			return terrain_ids[i]
		i += 1
			
	printerr("ProcGen cannot map noise to Terrain ID, noise_val:", noise_val)
	return terrain_ids[0] 

################################################################################### 
# Abstracting these functions away in case we want to change the functionality later
# Override if necessary

# Creates a square-sized noisemap that minimally covers the number of grids needed
func noiseSizeByNumBoard() -> Vector2:
	var temp = ceil(sqrt(num_board))
	return Vector2i(temp, temp)
	
func getOffsetByBoardId(board_id: int) -> Vector2i:
	var noise_width_bynumboard : int = noiseSizeByNumBoard().x 
	var x : int = board_id % noise_width_bynumboard
	var y : int = board_id / noise_width_bynumboard
	return Vector2i(x,y)

#func getTerrainAtCell(x : int, y : int):
	#return matrix[x][y]

func post_process(matrix : Array, sizex: int, sizey: int) -> void:
	for post in post_processors:
		post.process(matrix, sizex, sizey)
	pass

func assign_buildings(matrix : Array, board_id : int) -> void:
	pass
	
func add_buildings(matrix: Array, create_build: Callable) -> void:
	pass
####################################################################################
