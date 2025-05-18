extends Object
class_name BoardTile

var tile_built = false

# TODO:
# Currently we are storing all this data in card_database as an array
# See if we want to store it as a Resource or some other data later
var _terrain : EnvTerrain

# Array in case we have stackable buildings
# Should use it as a queue, where we calculate scoring from the base tile upwards
var buildings : Array[Building]

func _init(terrain : EnvTerrain):
	_terrain = terrain

func add_building(building : Building):
	buildings.push_back(building)
	
func change_terrain(terrain : EnvTerrain):
	_terrain = terrain
