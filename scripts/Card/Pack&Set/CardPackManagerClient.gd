extends CardPackManagerBase
class_name CardPackManagerClient

@export var spawn_node : Node

static var cardpack_created_total_count := 0

var card_pack_nodes : Array[CardPack]

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	Signalbus.connect("create_pack", create_pack)
	Signalbus.connect("choose_pack", func(chosen_packindex: int): \
		attempt_choose_pack.rpc_id(1, chosen_packindex))
	#NetworkManager.mark_client_ready(self.name)
	pass # Replace with function body.

@rpc("any_peer","call_local")
func create_pack(packs : Array[Array]) -> void:
	var card_pack : CardPack
	var card_pack_index := 0
	for p_index in range(len(packs)):
		card_pack = CardPack.new_pack(packs[p_index], p_index, cardpack_created_total_count)
		cardpack_created_total_count += 1
		card_pack.set_position(Vector2i(0,0))
		spawn_node.add_child(card_pack)
		card_pack_nodes.append(card_pack)

func _choose_pack(chosen_packindex : int) -> void:
	# TODO: REPLACE THIS 0
	CardLoader.cardpack_gen.update_local_cardpack_choice(chosen_packindex, 0)

@rpc("any_peer","call_local")
func remove_other_packs(pack_id : int) -> void:
	for i in range(len(card_pack_nodes)):
		if i != pack_id:
			card_pack_nodes[i].destroy_pack()
		else:
			card_pack_nodes[i].set_cardset_interactable()
			

	#var card_pack = CardPack.new_pack(sets)
	#card_pack.set_position(Vector2i(0,0))
	#spawn_node.add_child(card_pack)
#
#func get_setdata_from_id(sets : Array[String]) -> Array[CardSetData]:
	#var arr : Array[CardSetData]
	#for s in sets:
		#arr.append(card_set_dict[s])
	#return arr
