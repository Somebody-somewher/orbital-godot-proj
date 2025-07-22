extends Object
class_name PlayerCardMemory

var player_uuid : String
# Actual Card instances created/presented for each player
# This is a Dictionary nested in 3 layers
# Dictionary[int, Dictionary] -> Each pack has an id
# Dictionary[String, Dictionary] -> Each set has a string id too
# Dictionary[String, CardInstanceData] -> Each card has a set quantity
var cardpack_options : Dictionary[int, Dictionary] = {}

# Seleced cardpack inventory
# This is a Dictionary nested in 3 layers
# Dictionary[int, Dictionary] -> Each pack has an id
# Dictionary[String, Dictionary] -> Each set has a string id too
# Dictionary[String, CardInstanceData] -> Each card has a set quantity
var cardpack_inventory : Dictionary[int, Dictionary] = {}

# Is an array in case the card position is impt
var hand_instances : Array[CardInstanceData] = []
var default_maxhandsize := 10

# Called during CardPack Generation
func record_cardpack_options(card_packs : Dictionary[int, Dictionary]) -> void:
	cardpack_options = card_packs

# Called by CardPackChooser which is found in CardPackManager
func record_cardpack_choice(cardpack_id : int) -> void:
	cardpack_inventory[cardpack_id] = cardpack_options[cardpack_id]
	cardpack_options.clear()

func debug_check_cardpack_options_avail() -> void:
	assert(cardpack_options.is_empty())

################################# PLAYER HAND #####################################
# returns Array[Array[CardInstanceData] , Array[CardInstanceData]]
func attempt_cardset_to_hand(cardpack_id : int, cardset_id : String, remove_pack_after := true) -> Array[Array]:
	var added_card_instances : Array[CardInstanceData]
	var discarded_card_instances : Array[CardInstanceData]
	
	# At this point, card_set_options should be reduced to only the cardpack the player picked.
	if !cardpack_inventory.has(cardpack_id) or !cardpack_inventory[cardpack_id].has(cardset_id):
		printerr("Possible desync detected ", cardpack_id, cardset_id, cardpack_inventory)
		return []
	
	# The number of cards the player can take in (due to their max hand size)
	var numcards_to_hand = get_max_hand_size() - hand_instances.size()
	var cardset_cards : Dictionary[String, CardInstanceData] = cardpack_inventory[cardpack_id][cardset_id]
	
	var num_cardset_cards = cardset_cards.size()
	# Add as many cards to the hand as possible, keeping to the max_size_limit
	numcards_to_hand = min(numcards_to_hand, num_cardset_cards)
	
	var cards_in_set : Array[CardInstanceData] = cardset_cards.values()
	for i in range(num_cardset_cards):
		cards_in_set[i].set_owner_uuid(player_uuid)
		
		if i < numcards_to_hand:
			hand_instances.append(cards_in_set[i])
			added_card_instances.append(cards_in_set[i])	
		else:
			discarded_card_instances.append(cards_in_set[i])
			#trigger_discard_events.call(cards_in_set[i])
	
	if remove_pack_after:
		cardpack_inventory.erase(cardpack_id)
	else:
		cardpack_inventory[cardpack_id].erase(cardset_id)
	
	return [added_card_instances, discarded_card_instances]

func search_hand_for(instance_id : String) -> CardInstanceData:
	for c in hand_instances:
		if c.get_id() == instance_id:
			return c
	return null

func remove_card_in_hand(instance_id : String) -> CardInstanceData:
	var item = search_hand_for(instance_id)
	if item:
		hand_instances.erase(item)
	return item

func add_card_to_hand(card : CardInstanceData) -> bool:
	if hand_instances.size() >= get_max_hand_size():
		return false
	
	hand_instances.append(card)
	return true

#func remove_card_in_hand(instance_id : String, is_discard := false) -> bool:
	#var item = search_hand_for(instance_id)
	#if item:
		#if is_discard:
			#trigger_discard_events.call(item)
		#else:
			#trigger_play_events.call(item)
		#hand_instances.erase(item)
		#return true
	#else:
		#return false

func get_max_hand_size() -> int:
	return default_maxhandsize

func is_hand_full() -> bool:
	return len(hand_instances) == default_maxhandsize

# NOTE: need to have a serialize function for card instance data as well
#func serialize() -> Dictionary
