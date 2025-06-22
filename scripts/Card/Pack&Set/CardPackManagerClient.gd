extends CardPackManagerBase
class_name CardPackManagerClient

@export var spawn_node : CardManager

var card_pack_nodes : Array[CardPack]

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	CardLoader.setup_pack_creator(_create_pack)
	Signalbus.connect("server_pack_choosing_end", remove_other_packs)
	NetworkManager.mark_client_ready(self.name)
	pass # Replace with function body.
#
func _create_pack(packs : Array[Array]) -> void:
	var card_pack : CardPack
	var card_pack_index := 0
	for p in packs:
		card_pack = CardPack.new_pack(p, card_pack_index, \
			func(chosen_packid : int):
				attempt_choose_pack.rpc_id(1, chosen_packid))
		card_pack.set_position(Vector2i(0,0))
		spawn_node.add_child(card_pack)
		card_pack_nodes.append(card_pack)

@rpc("any_peer","call_local")
func remove_other_packs(pack_id : int) -> void:
	for i in range(len(card_pack_nodes)):
		if i != pack_id:
			card_pack_nodes[i].destroy_pack()
			

	#var card_pack = CardPack.new_pack(sets)
	#card_pack.set_position(Vector2i(0,0))
	#spawn_node.add_child(card_pack)
#
#func get_setdata_from_id(sets : Array[String]) -> Array[CardSetData]:
	#var arr : Array[CardSetData]
	#for s in sets:
		#arr.append(card_set_dict[s])
	#return arr
