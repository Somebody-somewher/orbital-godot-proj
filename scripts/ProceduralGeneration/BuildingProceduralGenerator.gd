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
		noise_building_texture = generate_noise_texture(0.9)

func assign_buildings(matrix : Array, board_id : int) -> void:
	assert(building_ids.size() >= building_noise_threshold.size())
	assert(building_ids.size() == terrain_conditions.size())
	if building_ids.size() > building_noise_threshold.size():
		printerr("Some Buildings tiles will not be generated")
	
	var offset : Vector2i = getOffsetByBoardId(board_id) * board_size
	var noise = noise_building_texture.noise
	var noise_val
	for col in range(board_size.x):
		for row in range(board_size.y):
			noise_val = noise.get_noise_2d(offset.x + col, offset.y + row)
			matrix[col][row].append(map_noise_to_building(noise_val, matrix[col][row][0]))
			#print(noise_val, matrix[col][row])
			
func add_buildings(matrix : Array, create_build : Callable) -> void:			
	for col in range(board_size.x):
		for row in range(board_size.y):
			if matrix[col][row][1] != "":
				create_build.call(Vector2i(col,row), Building.new_building(matrix[col][row][1]))
			
	
func map_noise_to_building(noise_val : float, current_terrain : String) -> String:
	var i = 0;
	for level in building_noise_threshold:
		if noise_val <= level && current_terrain in terrain_conditions[i]:
			return building_ids[i]
		i += 1
			
	return ""
	
