extends Resource
class_name EnvTerrainMapping

# This class ensures that every tile in the tileset is mapped to a string ID
# TODO: Maybe extend this to the building spritesheet if needed

@export var environment_pos : Dictionary[String, Vector2i] #Visual Name, 
@export var environment_data : Dictionary[String, EnvTerrain] #Visual Name, 
@export var tileset : TileSet = preload("res://Resources/EnvTerrain/EnvTerrainTileset.tres")
#@export var envterrain_grp : ResourceGroup = preload("res://Resources/ResourceGrps/EnvTerrainGrp.tres")

#
#func _init() -> void:
	#for path in envterrain_grp.paths:
		#var envterrain : EnvTerrain = load(path)
		#environment_data_set.get_or_add(envterrain, envterrain)
	#print(environment_data_set)
#
#func check_terrain_exists(terrain : EnvTerrain) -> bool:
	#return terrain.has(terrain)

func getTilePosbyEnv(terrain_id : String) -> Vector2i:
	return environment_pos.get(terrain_id)

func checkEnvExists(terrain_id : String) -> bool:
	return environment_pos.has(terrain_id)

func getPlaceholderTile() -> EnvTerrain:
	return environment_data.get("Grass")

#func getTilebyId(id : String) -> Vector2i:
	#return environment_data.get(id).tilesheet_pos
#
func getTileDatabyId(id : String) -> EnvTerrain:
	var result = environment_data.get(id) 
	assert(result != null)
	if result == null:
		printerr("TileID not recognized in EnvTerrainMapping, defaulting to Error tile")
		return environment_data.get("Error")
	
	return result
