extends Node2D
#TODO: If we convert Board to a TileMap, can just extend Object or sth

class_name BoardTile

var tile_built = false

signal mouse_over_tile
signal mouse_off_tile

# TODO:
# Currently we are storing all this data in card_database as an array
# See if we want to store it as a Resource or some other data later
var _terrain : Array

# Array in case we have stackable buildings
# Should use it as a queue, where we calculate scoring from the base tile upwards
var buildings : Array[Building]

func setup(terrain : Array):
	terrain = terrain

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	# I'm not sure if this line of code is impt since deleting it doesn't really affect the behaviour
	# commenting it off for now so that I can decouple the board_tile from CardManager
	#get_tree().root.get_child(0).get_node("CardManager").connect_tile_signals(self)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_card_flip_range_mouse_entered() -> void:
	emit_signal("mouse_over_tile", self)

func _on_card_flip_range_mouse_exited() -> void:
	emit_signal("mouse_off_tile", self)
