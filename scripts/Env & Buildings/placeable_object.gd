extends Node2D
class_name PlaceableObject
# abstract class handling functions of card object before they are placed

# predicates in the form of pred(self id in database, board, pos)
@export var place_conditions : Array[Resource] 

# As defined in card_database
@export var id_name : String
@export var layer : int # for stacking and rendering

func placeable(board, pos : Vector2i) -> bool:
	for condition in place_conditions:
		if !condition.can_place(id_name, board , pos):
			return false
	return true
