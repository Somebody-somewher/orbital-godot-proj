extends CardPackManagerBase
class_name CardPackManagerTutorial

@export var spawn_node : Node

var card_pack_nodes : Dictionary[int, CardPack]

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

@rpc("any_peer","call_local")
func create_pack() -> void:
	pass
	#var card_pack : CardPack
	#var pack_ids := packs.keys()
	#var pack_contents := packs.values()
	#
	#var packs_to_insert : Dictionary[String, Array]
	#
	#for pack_id in packs.keys():
		#card_pack = CardPack.new_pack(packs[pack_id], pack_id)
		##card_pack.set_position(Vector2i(0,0))
		#spawn_node.add_child(card_pack)
		#card_pack_nodes[pack_id] = card_pack

# Client-facing function rpc'd by Server
# Initiated when any player chooses a pack
@rpc("any_peer","call_local")
func _choose_pack_ui_update(chosen_packid : int, colour : Color) -> void:
	var cardpack : CardPack = card_pack_nodes[chosen_packid]
	
	#CardLoader.cardpack_gen.update_local_cardpack_choice(chosen_packindex, cardpack.get_id())
	
	cardpack.pack_chosen_update(colour)
	# Need a delay probably between deleting the pack and doing this action

@rpc("any_peer","call_local")
func finalize_pack_choices(pack_id : int) -> void:
	
	# Remove all remaining packs
	var temp : CardPack
	var to_erase : Array[int]
	
	for id in card_pack_nodes.keys():
		if id != pack_id:
			to_erase.append(id)
		else:
			card_pack_nodes[id].set_cardset_interactable(remove_pack)
			card_pack_nodes[id].make_sets_choosable()
	
	for id in to_erase:
		card_pack_nodes[id].destroy_pack()
		card_pack_nodes.erase(id)

# TODO: UPDATE TO ONLY REMOVE PACKS THAT ARE CURRENTLY BEING CHOSEN
#func remove_other_packs(pack_id : int) -> void:

## Pack calls this functions if it removes itself (i.e thru being selected)
# Needed cuz the pack has to remove the reference to itself in the array
func remove_pack(pack_id : int) -> void:
	var temp : CardPack
	print(card_pack_nodes)
	card_pack_nodes[pack_id].destroy_pack()
	card_pack_nodes.erase(pack_id)


	#var card_pack = CardPack.new_pack(sets)
	#card_pack.set_position(Vector2i(0,0))
	#spawn_node.add_child(card_pack)
#
#func get_setdata_from_id(sets : Array[String]) -> Array[CardSetData]:
	#var arr : Array[CardSetData]
	#for s in sets:
		#arr.append(card_set_dict[s])
	#return arr
