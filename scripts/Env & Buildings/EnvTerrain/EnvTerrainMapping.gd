extends Resource
class_name EnvTerrainMapping

# This class ensures that every tile in the tileset is mapped to a string ID
# TODO: Maybe extend this to the building spritesheet if needed

@export var environment_data : Dictionary[String, EnvTerrain] #Visual Name, 
@export var tileset : TileSet = preload("res://Resources/EnvTerrain/EnvTerrainTileset.tres")

func getTilebyId(id : String) -> Vector2i:
	return environment_data.get(id).tilesheet_pos

func getTileDatabyId(id : String) -> EnvTerrain:
	var result = environment_data.get(id) 
	
	if result == null:
		printerr("TileID not recognized in EnvTerrainMapping, defaulting to Error tile")
		return environment_data.get("Error")
	
	return result
