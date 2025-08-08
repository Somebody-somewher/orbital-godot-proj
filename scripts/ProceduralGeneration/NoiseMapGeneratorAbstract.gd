extends Resource
class_name NoiseMapGeneratorAbstract

var noise_highlight_texture : NoiseTexture2D
@export var terrain_noise_freq : float =  0.0583
var cache : Dictionary 

## Values should be sorted in ascending order otherwise noise check die
@export var noise_threshold : Array[float]
@export var _items : Array

var _board_size : Vector2i
# x -> Width y -> Height
var _board_num_width_height : Vector2i
var _border_width : Vector2i

@export var _gen_size : Vector2i

func generate_weights(array_items : Array, min_val := -0.6, max_val := 0.7, skew := 0.1) -> void:
	var n := len(array_items)
	var sum := 0.0
	var indiv_val := 0.0
	var range_val = max_val - min_val
	var cum_sum := 0.0
	var weights : Array
	
	for i in range(n):
		indiv_val = 1 / ((i + 1)**(skew))
		weights.append(indiv_val)
		sum += indiv_val
	
	var temp
	for i in len(weights):
		temp = (weights[i] / sum)
		weights[i] = cum_sum + temp
		cum_sum += temp
		weights[i] = weights[i] * range_val + min_val
	
	#noise_threshold.assign(weights.slice(0, len(weights) - 2))
	noise_threshold.assign(weights)
	print(weights)
	
# Call this to start the proc_gen (can be called multiple times without error)
func set_up(board_size : Vector2i = Vector2i(8,8), board_num : Vector2i = Vector2i(1,1), \
		border_width : Vector2i = Vector2i(0,0), items : Array = _items, seedz : int = -1) -> void:
	#randomize()
	
	_board_size = board_size
	_board_num_width_height = board_num
	_border_width = border_width
	
	if len(_items) != len(items) and len(items) != 0:
		generate_weights(items)
	
	_items = items
	
	_gen_size = Vector2i(board_size.x * board_num.x + border_width.x * 2, board_size.y * board_num.y + border_width.y * 2)
	# If noise texture is not provided, we randomize a new one
	if noise_highlight_texture == null:
		noise_highlight_texture = generate_noise_texture(terrain_noise_freq, seedz)

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
	noise_texture.set_width(_gen_size.x)
	noise_texture.set_height(_gen_size.y)
	noise_texture.set_normalize(true)
	
	# I wanted to try to make this noisemap seamless
	# i.e wrap around, but seems like it no want to cooperate
	# noise_texture.set_seamless(true)
	# noise_texture.set_seamless_blend_skirt(9.0)
	
	noise_texture.set_noise(noise)
	return noise_texture

func post_process(_procgen_iterator : ProcGenBoardIterator) -> void:
	pass

func generate_world() -> ProcGenBoardIterator:
	var matrix = ProcGenBoardIterator.new(make_matrix(), _board_size, _board_num_width_height, _border_width)
	post_process(matrix)
	return matrix

# TO OVERRIDE
func make_matrix() -> Array:
	return []

func reset() -> void:
	noise_highlight_texture = null
	cache.clear()
