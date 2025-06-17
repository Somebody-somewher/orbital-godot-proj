extends Node
class_name CardPackManagerBase

@export var cardset_grp : ResourceGroup
var card_set_arr : Array[CardSetData] = []


var cardset_allocator : CardSetAllocator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cardset_grp.load_all_into(card_set_arr)
	
	if multiplayer.is_server():
		cardset_allocator = CardSetAllocator.new(card_set_arr, func(player_id : int, sets : Array[String]) : \
		create_pack.rpc_id(player_id, sets))
	pass # Replace with function body.

func create_pack(sets : Array[String]) -> void:
	pass
