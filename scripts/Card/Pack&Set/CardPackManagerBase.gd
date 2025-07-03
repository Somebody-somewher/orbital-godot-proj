extends Node
class_name CardPackManagerBase

var cardpack_chooser : CardPackChooser

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if multiplayer.is_server():
		cardpack_chooser = CardPackChooser.new(\
			func(peerid : int, chosen_packid : int, colour : Color): 
				_choose_pack_ui_update.rpc_id(peerid, chosen_packid, colour),\
			func(peerid : int, chosen_packindex : int): 
				finalize_pack_choices.rpc_id(peerid, chosen_packindex))
	
	pass # Replace with function body.

## Called via signal->rpc from cardpack instance -> Server's CardPackChooser handles server side 
@rpc("any_peer","call_local")
func attempt_choose_pack(chosen_packindex : int) -> void:
	var successfully_chosen : bool
	successfully_chosen = cardpack_chooser.player_choose_pack( \
		PlayerManager.getUUID_from_PeerID(multiplayer.get_remote_sender_id()), chosen_packindex)
	
	#if successfully_chosen:
		#_choose_pack_ui_update.rpc_id(multiplayer.get_remote_sender_id(), chosen_packindex)
	

	# Colour pack based on which player chose the pack?	
	#card_pack_nodes[chosen_packindex].choose_pack_update(Color.RED)

@rpc("any_peer","call_local")
func _choose_pack_ui_update(chosen_packindex : int, colour : Color) -> void:
	pass

@rpc("any_peer","call_local")
func finalize_pack_choices(chosen_packindex : int) -> void:
	pass
