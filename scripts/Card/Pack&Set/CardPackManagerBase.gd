extends Node
class_name CardPackManagerBase

@export var remove_used_sets := false
@export var cardset_grp : ResourceGroup
var card_set_arr : Array[CardSetData] = []

var cardset_allocator : CardSetAllocator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cardset_grp.load_all_into(card_set_arr)
	if multiplayer.is_server():
		cardset_allocator = CardSetAllocator.new(cardset_grp, remove_used_sets)
	NetworkManager.connect("all_clients_ready", query_server_for_cards)
	pass # Replace with function body.

# Overriden by CardPackManagerClient, will be rpc'called by CardLoader once cards queried
func create_pack(sets : Array[Array]) -> void:
	pass

func query_server_for_cards() -> void:
	print(cardset_allocator.get_packs())
	CardLoader.get_cards_for_pack(cardset_allocator.get_packs(), cardset_allocator.get_player_num_options())
