extends Resource
class_name EnvTerrainMapping

# This class ensures that every tile in the tileset is mapped to a string ID
# TODO: Maybe extend this to the building spritesheet if needed

@export var environment_data : Dictionary[EnvTerrain, Vector2i] #Visual Name, 
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

func getTilePosbyEnv(terrain : EnvTerrain) -> Vector2i:
	return environment_data.get(terrain)

func checkEnvExists(terrain : EnvTerrain) -> bool:
	return environment_data.has(terrain)

func getPlaceholderTile() -> EnvTerrain:
	return environment_data.keys()[0]

#func getTilebyId(id : String) -> Vector2i:
	#return environment_data.get(id).tilesheet_pos
#
#func getTileDatabyId(id : String) -> EnvTerrain:
	#var result = environment_data.get(id) 
	#
	#if result == null:
		#printerr("TileID not recognized in EnvTerrainMapping, defaulting to Error tile")
		#return environment_data.get("Error")
	#
	#return result
