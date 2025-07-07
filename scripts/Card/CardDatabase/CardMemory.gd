extends Node
class_name CardMemory
# Contain the instances of CardDataInstance

# Actual Card instances created/presented for each player
var local_player_memory : PlayerCardMemory

func setup() -> void:
	local_player_memory = PlayerCardMemory.new()

func record_player_cardpack_options(card_packs : Dictionary[int, Dictionary]) -> void:
	local_player_memory.record_cardpack_options(card_packs)

# Called by CardPackChooser which is found in CardPackManager
@rpc("any_peer", "call_local")
func _record_player_cardpack_choice(cardpack_id : int) -> void:
	local_player_memory.record_cardpack_choice(cardpack_id)

################################# PLAYER HAND #####################################
func local_search_hand_for(instance_id : String) -> CardInstanceData:
	return local_player_memory.search_hand_for(instance_id)

func local_attempt_to_use_hand_card(instance_id : String) -> CardInstanceData:
	return local_player_memory.attempt_to_use_hand_card(instance_id)

@rpc("any_peer", "call_local")
func _attempt_cardset_to_hand(cardpack_id : int, cardset_id : String, cardinstanceids_to_add : Array[String]) -> void:
	var result = local_player_memory.attempt_cardset_to_hand(cardpack_id, cardset_id)
	Signalbus.emit_signal("confirmed_add_to_hand", cardinstanceids_to_add, cardset_id)

@rpc("any_peer", "call_local")
func _remove_card_in_hand(instance_id : String) -> void:
	local_player_memory.remove_card_in_hand(instance_id)
	
#func _add_card_to_hand()	

#func append_to_player_hand(player_uuid : String, card_set : Array[int], add_to_hand : Callable) -> bool:
	#if player_hand_instances[player_uuid].size() >= player_maxhandsize[player_uuid]:
		## CARD DISCARDED
		#return false
		#
	##player_hand_instances[player_uuid].append(card_instance)
	#return true

####################################################################################
