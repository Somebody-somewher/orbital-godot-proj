extends CardMemory
class_name ServerCardMemory
# Contain the instances of CardDataInstance

# Actual Card instances created/presented for each player
func setup(sync_card_creation : Callable, create_card : Callable) -> void:
	func_sync_card_creation = sync_card_creation
	func_create_card = create_card	
	
	self_uuid = PlayerManager.getCurrentPlayerUUID()
	PlayerManager.forEachPlayer(func(pi : PlayerInfo): \
		var mem := PlayerCardMemory.new();\
		mem.player_uuid = pi.getPlayerUUID();\
		player_memory.get_or_add(pi.getPlayerUUID(), mem));

func event_manager_setup(register_events : Callable, trigger_events : Callable) -> void:
	super.event_manager_setup(register_events, trigger_events)
	
	#PlayerManager.forEachPlayer(func(pi : PlayerInfo): \
		#Signalbus.round_start.connect(func(_round_id : String, round_total : int):\
			#player_memory[pi.getPlayerUUID()].foreach_card_in_hand(\
				#func(cid : CardInstanceData):
					#trigger_events.call(cid, "on_begin_round", round_total))))
	#
	#PlayerManager.forEachPlayer(func(pi : PlayerInfo): \
		#Signalbus.round_end.connect(func(_round_id : String, round_total : int):\
			#player_memory[pi.getPlayerUUID()].foreach_card_in_hand(\
				#func(cid : CardInstanceData):
					#trigger_events.call(cid, "on_end_round", round_total))))

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
		func_register_events.call(instance)
		string_ids.append(instance.get_id())
	
	# Technically this means the card enters the hand and then gets discarded immediately
	for instance in result[1]:
		func_register_events.call(instance)
		func_trigger_events.call(instance, "on_discard", [])
		
	if !PlayerManager.amIPlayer(player_uuid):
		var peer_id = PlayerManager.getPeerID_from_UUID(player_uuid)
		_attempt_cardset_to_hand.rpc_id(peer_id, cardpack_id, cardset_id, string_ids)
	else:
		Signalbus.confirmed_add_to_hand.emit(string_ids, cardset_id)
		
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
	func_trigger_events.call(instance)
	
	if !PlayerManager.amIPlayer(player_uuid):
		var peer_id = PlayerManager.getPeerID_from_UUID(player_uuid)
		_remove_card_in_hand.rpc_id(peer_id, instance_id)		

	return instance

func remove_card_in_hand(instance_id : String, player_uuid : String) -> void:
	var instance = player_memory[player_uuid].remove_card_in_hand(instance_id)
	func_trigger_events.call(instance, "on_discard", [])
	
	if !PlayerManager.amIPlayer(player_uuid):
		var peer_id = PlayerManager.getPeerID_from_UUID(player_uuid)
		_remove_card_in_hand.rpc_id(peer_id, instance_id)
	
func add_card_in_hand(instance_data : CardInstanceData, player_uuid : String, pos : Vector2 = Vector2.ZERO) -> void:
	func_register_events.call(instance_data)
	
	if player_memory[player_uuid].is_hand_full():
		func_trigger_events.call(instance_data, "on_discard", [])
		return
		
	player_memory[player_uuid].add_card_to_hand(instance_data)
	
	if !PlayerManager.amIPlayer(player_uuid):
		var peer_id = PlayerManager.getPeerID_from_UUID(player_uuid)
		_add_card_in_hand.rpc_id(peer_id, instance_data.serialize())
	else:
		var card : Card = func_create_card.call(instance_data)
		card.position = pos
		Signalbus.register_to_cardmanager.emit(card)
		Signalbus.add_to_hand.emit(card)
	

func is_hand_full(player_uuid : String) -> bool:
	return player_memory[player_uuid].is_hand_full()
####################################################################################


	 

#func run_for_client(player_uuid : String, server_client_c : Callable, other_client_c : Callable) -> void:
	#if NetworkManager.is_client() and PlayerManager.amIPlayer(player_uuid):
		#server_client_c.call()
	#else:
		#other_client_c.call()
