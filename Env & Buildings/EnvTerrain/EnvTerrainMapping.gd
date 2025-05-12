extends Resource
class_name EnvTerrainMapping

# This needs to be synced together with the spritesheet
# These default values don't work btw :< 

@export var environment_data : Dictionary[String, EnvTerrain] #Visual Name, Base Score, sprite_path

@export var tileset : TileSet = preload("res://Env & Buildings/EnvTerrain/EnvTerrainTileset.tres")
func getTilebyId(id : String) -> Vector2i:
	return environment_data.get(id).tilesheet_pos

func getTileDatabyId(id : String) -> EnvTerrain:
	return environment_data.get(id, "Grass")
