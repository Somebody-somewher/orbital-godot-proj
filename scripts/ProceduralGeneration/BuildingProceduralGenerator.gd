extends ProceduralGenerator
class_name BuildingProceduralGenerator

# Actually noise map to generate the map
@export var noise_building_texture : NoiseTexture2D
@export var noise_building_freq : float
var noise_building : Noise

@export var building_noise_threshold : Array[float]
@export var building_ids : Array[String]
@export var terrain_conditions : Array[Array]

func set_up() -> void:
	super.set_up()
	if noise_building_texture == null:
		noise_building_texture = generateNoiseTexture(0.9)

	
func generate_world(board_id : int = 0):
	assert(building_ids.size() >= building_noise_threshold.size())
	assert(building_ids.size() == terrain_conditions.size())
	if building_ids.size() > building_noise_threshold.size():
		printerr("Some Buildings tiles will not be generated")
	
	var matrix = super.generate_world(board_id)
	var offset : Vector2i = getOffsetByBoardId(board_id) * board_size
	var noise = noise_building_texture.noise
	var noise_val
	for col in range(board_size.x):
		for row in range(board_size.y):
			noise_val = noise.get_noise_2d(offset.x + col, offset.y + row)
			matrix[col][row].append(map_noise_to_building(noise_val, matrix[col][row][0]))
			#print(noise_val, matrix[col][row])
	return matrix
	
func map_noise_to_building(noise_val : float, current_terrain : String) -> String:
	var i = 0;
	for level in building_noise_threshold:
		if noise_val <= level && current_terrain in terrain_conditions[i]:
			return building_ids[i]
		i += 1
			
	return ""
	
