extends BoardEvent
class_name PlaceCheckEvent

@export var effect_when_true : BoardEvent
@export var effect_when_false : BoardEvent
@export var triggering_buildings : Array[String]

#check if its palced on any of the triggering buildings, then trigger appropritae event 
#
#func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : Node2D) -> void:
	#pass
