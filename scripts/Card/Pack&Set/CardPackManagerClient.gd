extends CardPackManagerBase
class_name CardPackManagerClient

@export var spawn_node : Node

var card_pack_nodes : Dictionary[int, CardPack]

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	Signalbus.connect("create_pack", create_pack)
	Signalbus.connect("choose_pack", func(chosen_packindex: int): \
		attempt_choose_pack.rpc_id(1, chosen_packindex))
	#NetworkManager.mark_client_ready(self.name)
	pass # Replace with function body.

@rpc("any_peer","call_local")
func create_pack(packs : Dictionary[int, Dictionary]) -> void:
	var card_pack : CardPack
	var pack_ids := packs.keys()
	var pack_contents := packs.values()
	
	var packs_to_insert : Dictionary[String, Array]
	
	for pack_id in range(len(packs)):
		packs_to_insert.assign(packs[pack_id])
		card_pack = CardPack.new_pack(packs_to_insert, pack_id)
		card_pack.set_position(Vector2i(0,0))
		spawn_node.add_child(card_pack)
		card_pack_nodes[pack_id] = card_pack

# Client-facing function rpc'd by Server
# Initiated when any player chooses a pack
@rpc("any_peer","call_local")
func _choose_pack_ui_update(chosen_packid : int, colour : Color) -> void:
	var cardpack : CardPack = card_pack_nodes[chosen_packid]
	
	#CardLoader.cardpack_gen.update_local_cardpack_choice(chosen_packindex, cardpack.get_id())
	
	cardpack.pack_chosen_update(colour)
	

@rpc("any_peer","call_local")
func finalize_pack_choices(pack_id : int) -> void:
	
	# Remove all remaining packs
	var temp : CardPack
	for pack in card_pack_nodes.values():
		if pack.pack_id != pack_id:
			temp = pack
			card_pack_nodes.erase(temp)
			temp.destroy_pack()
		else:
			pack.set_cardset_interactable(remove_pack)
			pack.make_sets_choosable()

# TODO: UPDATE TO ONLY REMOVE PACKS THAT ARE CURRENTLY BEING CHOSEN
#func remove_other_packs(pack_id : int) -> void:

## Pack calls this functions if it removes itself (i.e thru being selected)
# Needed cuz the pack has to remove the reference to itself in the array
func remove_pack(pack_id : int) -> void:
	var temp : CardPack
	for pack in card_pack_nodes.values():
		if pack.pack_id == pack_id:
			temp = pack
			card_pack_nodes.erase(temp)
			temp.destroy_pack()
			break



	#var card_pack = CardPack.new_pack(sets)
	#card_pack.set_position(Vector2i(0,0))
	#spawn_node.add_child(card_pack)
#
#func get_setdata_from_id(sets : Array[String]) -> Array[CardSetData]:
	#var arr : Array[CardSetData]
	#for s in sets:
		#arr.append(card_set_dict[s])
	#return arr
