extends Node
class_name CardPackManager

#TODO: Remove later
@export var spawn_node : CardManager

var card_set_arr = []

@export var cardset_grp : ResourceGroup

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cardset_grp.load_all_into(card_set_arr)
	NetworkManager.client_ready_to_server()
	pass # Replace with function body.

func create_pack(sets : Array[CardSetData]) -> void:
	pass
	#var card_pack = CardPack.new_pack(CardLoader.get_random_set(4))
	#card_pack.set_position(Vector2i(0,0))
	#spawn_node.add_child(card_pack)
