extends Resource
class_name ProceduralGenerator

# Actually noise map to generate the map
@export var noise_highlight_texture : NoiseTexture2D
var noise : Noise

# Pair of noise_value -> terrain, noise vals should be between -0.6 to 0.5
# Values should be sorted in ascending order
@export var noise_terrain_threshold : Dictionary[float, String]

#temp
@export var width : int = 100
@export var height : int = 100

var matrix

func _init():
	matrix = Array()
	matrix.resize(width);
	for i in range(width):
		matrix[i] = Array()
		matrix[i].resize(height)

# Generates a 2d matrix, each cell containing a terrarin resource
# based off the noise map
func generate_world() -> Array:
	noise = noise_highlight_texture.noise
	var noise_val : float
	for x in range(width):
		for y in range(height):
			noise_val = noise.get_noise_2d(x,y)
			
			# Mapping each cell to a (pointer to) terrain-data based off noisemap
			for noise_threshold in noise_terrain_threshold.keys():
				if noise_val <= noise_threshold:
					matrix[x][y] = noise_terrain_threshold[noise_threshold]
					break;
	
	return matrix
	
func getTerrainAtCell(x : int, y : int):
	return matrix[x][y]
