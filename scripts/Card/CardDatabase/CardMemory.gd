extends Node
class_name CardMemory
# Contain the instances of CardDataInstance

var self_uuid : String 

# Actual Card instances created/esented for each player
var player_memory : Dictionary[String, PlayerCardMemory]

var register_events : Callable
var trigger_play_events : Callable
var trigger_discard_events : Callable

var func_sync_card_creation : Callable
var func_create_card : Callable

func setup(sync_card_creation : Callable, create_card : Callable) -> void:
	
	func_sync_card_creation = sync_card_creation
	func_create_card = create_card
	var local_player_memory = PlayerCardMemory.new()
	self_uuid = PlayerManager.getCurrentPlayerUUID()
	local_player_memory.player_uuid = self_uuid
	player_memory = {self_uuid: local_player_memory}

func event_manager_setup(register_events : Callable, trigger_play : Callable, trigger_discard : Callable) -> void:
	self.register_events = register_events
	self.trigger_play_events = trigger_play
	self.trigger_discard_events = trigger_discard

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
	
	assert(len(result[0]) == len(cardinstanceids_to_add))
	
	for index in range(len(result[0])):
		register_events.call(result[0])
		assert(result[0][index].get_id() == cardinstanceids_to_add)
	
	Signalbus.confirmed_add_to_hand.emit(cardinstanceids_to_add, cardset_id)

@rpc("any_peer", "call_local")
func _attempt_to_use_hand_card(instance_id : String, player_uuid : String) -> void:
	var result = player_memory[self_uuid].remove_card_in_hand(instance_id)
	
@rpc("any_peer", "call_local")
func _remove_card_in_hand(instance_id : String) -> void:
	player_memory[self_uuid].remove_card_in_hand(instance_id)

@rpc("any_peer", "call_local")
func _add_card_in_hand(instance_deserialized_data : Dictionary) -> void:
	var instance : CardInstanceData = func_sync_card_creation.call(instance_deserialized_data)
	player_memory[self_uuid].add_card_to_hand(instance)
	var card : Card = func_create_card.call(instance)
	Signalbus.register_to_cardmanager.emit(card)
	Signalbus.add_to_hand.emit(card)

func retrieve_memory() -> Dictionary[String, PlayerCardMemory]:
	return player_memory
#func _add_card_to_hand()	

@rpc("any_peer", "call_local")
func server_record_player_cardpack_options(card_packs : Dictionary[int, Dictionary], player_uuid : String) -> void:
	print("This shouldn't trigger 1 :<")

@rpc("any_peer", "call_local")
func attempt_cardset_to_hand(cardpack_id : int, cardset_id : String, player_uuid : String) -> Array[String]:
	print("This shouldn't trigger 2 :<")
	return ["This should have been overriden! :<"]
#func append_to_player_hand(player_uuid : String, card_set : Array[int], add_to_hand : Callable) -> bool:
	#if player_hand_instances[player_uuid].size() >= player_maxhandsize[player_uuid]:
		## CARD DISCARDED
		#return false
		#
	##player_hand_instances[player_uuid].append(card_instance)
	#return true

####################################################################################
