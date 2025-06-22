extends Node
class_name CardPackManagerBase

@export var remove_used_sets := false
@export var cardset_grp : ResourceGroup
var card_set_arr : Array[CardSetData] = []

var cardset_allocator : CardSetAllocator
var cardpack_chooser : CardPackChooser

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cardset_grp.load_all_into(card_set_arr)
	if multiplayer.is_server():
		cardset_allocator = CardSetAllocator.new(cardset_grp, remove_used_sets)
		cardpack_chooser = CardPackChooser.new( \
			func(peerid : int, chosen_packid : int): 
				remove_other_packs.rpc_id(peerid, chosen_packid), \
			func(peerid : int, chosen_packid : int): 
				_choose_pack.rpc_id(peerid, chosen_packid))
	Signalbus.connect("server_create_packs", create_pack)
	pass # Replace with function body.

# Overriden by CardPackManagerClient, will be rpc'called by CardLoader once cards queried
func _create_pack(sets : Array[Array]) -> void:
	pass

@rpc("any_peer","call_local")
func _choose_pack(pack_id : int) -> void:
	pass

# Called by server
func create_pack() -> void:
	var cardpacks = cardset_allocator.get_packs()
	CardLoader.get_cards_for_pack(cardpacks, cardset_allocator.get_player_num_options())

## Passed to & Called by client cardpack -> server's CardPackChooser -> _choose_pack on Client activated
@rpc("any_peer","call_local")
func attempt_choose_pack(chosen_packid : int) -> void:
	cardpack_chooser.player_choose_pack(PlayerManager.getUUID_from_PeerID(multiplayer.get_remote_sender_id()), chosen_packid)

## Called by client
@rpc("any_peer","call_local")
func remove_other_packs(chosen_packid : int) -> void:
	pass
