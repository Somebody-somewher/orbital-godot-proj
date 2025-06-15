extends Resource
class_name EnvTerrain
# Useless now
# However, I need it as a class for the Polymorphism so that the board signal

@export var id_name : String
@export var score_modifier : int

func get_id() -> String:
	return id_name
