extends PlaceableData
class_name BuildingData
# In an ideal world BuildingData should not need to retrieve variables or methods from another BuildingData
# The only interaction between BuildingData-to-BuildingData is an equivalence check

@export_category("Building Properties")
@export var layer : int = 1
@export var nonplaceable_terrain : Array[EnvTerrain] = [preload("res://Resources/EnvTerrain/TerrainTiles/Water.tres")]
