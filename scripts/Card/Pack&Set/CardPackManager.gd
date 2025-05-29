extends Node
class_name CardPackManager

@export var card_pack : PackedScene

#TODO: Remove later
@export var spawn_node : CardManager

var card_set_arr = []

@export var cardset_grp : ResourceGroup

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cardset_grp.load_all_into(card_set_arr)
	pass # Replace with function body.

func create_pack() -> void:
	var c = card_pack.instantiate()
	c.set_position(Vector2i(300,300))
	spawn_node.add_child(c)
