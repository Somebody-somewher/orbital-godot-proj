extends Node
class_name CardPackManagerBase

var cardpack_chooser : CardPackChooser

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if multiplayer.is_server():
		cardpack_chooser = CardPackChooser.new( \
			func(peerid : int, chosen_packid : int): 
				remove_other_packs.rpc_id(peerid, chosen_packid))
	
	pass # Replace with function body.

@rpc("any_peer","call_local")
func _choose_pack(pack_id : int) -> void:
	#CardLoader.update_local_cardpack_choice(pack_id)
	pass

## Called via signal->rpc from cardpack instance -> Server's CardPackChooser handles server side 
@rpc("any_peer","call_local")
func attempt_choose_pack(chosen_packid : int) -> void:
	var successfully_chosen : bool
	successfully_chosen = cardpack_chooser.player_choose_pack( \
		PlayerManager.getUUID_from_PeerID(multiplayer.get_remote_sender_id()), chosen_packid)
	
	if successfully_chosen:
		_choose_pack.rpc_id(multiplayer.get_remote_sender_id(), chosen_packid)
	
## Called by client
@rpc("any_peer","call_local")
func remove_other_packs(chosen_packid : int) -> void:
	pass
