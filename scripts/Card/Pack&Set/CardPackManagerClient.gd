extends CardPackManagerBase
class_name CardPackManagerClient

var card_set_dict = {}

@export var spawn_node : CardManager
#
## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	CardLoader.setup_pack_creator(create_pack)
	NetworkManager.mark_client_ready(self.name)
	pass # Replace with function body.
#
func create_pack(sets : Array[Array]) -> void:
	print(sets)
	pass
	#var card_pack = CardPack.new_pack(sets)
	#card_pack.set_position(Vector2i(0,0))
	#spawn_node.add_child(card_pack)
#
#func get_setdata_from_id(sets : Array[String]) -> Array[CardSetData]:
	#var arr : Array[CardSetData]
	#for s in sets:
		#arr.append(card_set_dict[s])
	#return arr
