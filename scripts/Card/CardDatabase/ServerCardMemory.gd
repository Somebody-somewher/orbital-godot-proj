extends CardMemory
class_name ServerCardMemory
# Contain the instances of CardDataInstance

# Actual Card instances created/presented for each player
func setup() -> void:
	#if NetworkManager.is_client():
		#local_player_memory = PlayerCardMemory.new()
		#local_player_memory.player_uuid = PlayerManager.getCurrentPlayerUUID()
	self_uuid = PlayerManager.getCurrentPlayerUUID()
	PlayerManager.forEachPlayer(func(pi : PlayerInfo): \
		var mem := PlayerCardMemory.new();\
		mem.player_uuid = pi.getPlayerUUID();\
		player_memory.get_or_add(pi.getPlayerUUID(), mem));

@rpc("any_peer", "call_local")
func server_record_player_cardpack_options(card_packs : Dictionary[int, Dictionary], player_uuid : String) -> void:
	player_memory[player_uuid].record_cardpack_options(card_packs)

# Called by CardPackChooser which is found in CardPackManager
func record_player_cardpack_choice(cardpack_id : int, player_uuid : String) -> void:
	player_memory[player_uuid].record_cardpack_choice(cardpack_id)

	if !PlayerManager.amIPlayer(player_uuid):
		var peer_id = PlayerManager.getPeerID_from_UUID(player_uuid)
		_record_player_cardpack_choice.rpc_id(peer_id, cardpack_id)


################################# PLAYER HAND #####################################
@rpc("any_peer","call_local")
func attempt_cardset_to_hand(cardpack_id : int, cardset_id : String, player_uuid : String) -> Array[String]:
	
	var result : Array[Array] = player_memory[player_uuid].attempt_cardset_to_hand(cardpack_id, cardset_id)
	var string_ids : Array[String] = []
		
	for instance in result[0]:
		register_events.call(instance)
		string_ids.append(instance.get_id())
	
	# Technically this means the card enters the hand and then gets discarded immediately
	for instance in result[1]:
		register_events.call(instance)
		trigger_discard_events.call(instance)
	
	Signalbus.emit_signal("confirmed_add_to_hand", string_ids, cardset_id)
	
	if !PlayerManager.amIPlayer(player_uuid):
		var peer_id = PlayerManager.getPeerID_from_UUID(player_uuid)
		_attempt_cardset_to_hand.rpc_id(peer_id, cardpack_id, cardset_id, string_ids)

	return string_ids

#func append_to_player_hand(player_uuid : String, card_set : Array[int], add_to_hand : Callable) -> bool:
	#if player_hand_instances[player_uuid].size() >= player_maxhandsize[player_uuid]:
		## CARD DISCARDED
		#return false
		#
	##player_hand_instances[player_uuid].append(card_instance)
	#return true

func search_hand_for(instance_id : String, player_uuid : String) -> CardInstanceData:
	return player_memory[player_uuid].search_hand_for(instance_id)

func attempt_to_use_hand_card(instance_id : String, player_uuid : String) -> CardInstanceData:
	var instance = player_memory[player_uuid].remove_card_in_hand(instance_id)
	trigger_play_events.call(instance)
	
	if !PlayerManager.amIPlayer(player_uuid):
		var peer_id = PlayerManager.getPeerID_from_UUID(player_uuid)
		_remove_card_in_hand.rpc_id(peer_id, instance_id)		

	return instance

func remove_card_in_hand(instance_id : String, player_uuid : String) -> void:
	var instance = player_memory[player_uuid].remove_card_in_hand(instance_id)
	trigger_discard_events.call(instance)
	
	if !PlayerManager.amIPlayer(player_uuid):
		var peer_id = PlayerManager.getPeerID_from_UUID(player_uuid)
		_remove_card_in_hand.rpc_id(peer_id, instance_id)
	
	
####################################################################################

#func run_for_client(player_uuid : String, server_client_c : Callable, other_client_c : Callable) -> void:
	#if NetworkManager.is_client() and PlayerManager.amIPlayer(player_uuid):
		#server_client_c.call()
	#else:
		#other_client_c.call()
