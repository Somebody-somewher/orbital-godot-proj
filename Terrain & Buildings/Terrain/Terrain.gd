extends Resource
class_name Terrain

@export var name : String
@export var image : Texture2D = preload("res://sprites/grass.png")

# Base score of placing this building down
@export var base_score : int = 0;
