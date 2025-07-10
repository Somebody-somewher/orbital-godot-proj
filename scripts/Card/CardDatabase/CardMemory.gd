extends Node
class_name CardMemory
# Contain the instances of CardDataInstance

var self_uuid : String 

# Actual Card instances created/esented for each player
var player_memory : Dictionary[String, PlayerCardMemory]

func setup() -> void:
	var local_player_memory = PlayerCardMemory.new()
	self_uuid = PlayerManager.getCurrentPlayerUUID()
	local_player_memory.player_uuid = self_uuid
	player_memory = {self_uuid: local_player_memory}
	
func record_player_cardpack_options(card_packs : Dictionary[int, Dictionary]) -> void:
	player_memory[self_uuid].record_cardpack_options(card_packs)

# Called by CardPackChooser which is found in CardPackManager
@rpc("any_peer", "call_local")
func _record_player_cardpack_choice(cardpack_id : int) -> void:
	player_memory[self_uuid].record_cardpack_choice(cardpack_id)

################################# PLAYER HAND #####################################
func local_search_hand_for(instance_id : String) -> CardInstanceData:
	return player_memory[self_uuid].search_hand_for(instance_id)

@rpc("any_peer", "call_local")
func _attempt_cardset_to_hand(cardpack_id : int, cardset_id : String, cardinstanceids_to_add : Array[String]) -> void:
	var result = player_memory[self_uuid].attempt_cardset_to_hand(cardpack_id, cardset_id)
	Signalbus.emit_signal("confirmed_add_to_hand", cardinstanceids_to_add, cardset_id)

@rpc("any_peer", "call_local")
func _remove_card_in_hand(instance_id : String) -> void:
	player_memory[self_uuid].remove_card_in_hand(instance_id)

func retrieve_memory() -> Dictionary[String, PlayerCardMemory]:
	return player_memory
#func _add_card_to_hand()	

#func append_to_player_hand(player_uuid : String, card_set : Array[int], add_to_hand : Callable) -> bool:
	#if player_hand_instances[player_uuid].size() >= player_maxhandsize[player_uuid]:
		## CARD DISCARDED
		#return false
		#
	##player_hand_instances[player_uuid].append(card_instance)
	#return true

####################################################################################
