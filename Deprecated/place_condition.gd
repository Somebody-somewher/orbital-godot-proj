extends Resource
class_name PlaceCondition

static var database_ref = preload("res://scripts/Card/card_database.gd")

func can_place(_id_name : String, _board_matrix, _tile_pos : Vector2i) -> bool:
	return false
