extends Object
class_name ServerCardMemory
# Contain the instances of CardDataInstance

var card_count : int = 0 

# Actual Card instances created/presented for each player
# Array[Array] where each index represents a set containing card instances 
var cardpack_options : Dictionary[String, Array] = {}
#var cardpacks_generated : int

var player_hand_instances : Dictionary[String, Array] = {}
var player_maxhandsize : Dictionary[String, int] = {}
var DEFAULT_HANDSIZE := 10

func setup() -> void:
	PlayerManager.forEachPlayer(func(pi : PlayerInfo): \
		cardpack_options.get_or_add(pi.getPlayerUUID(), []); \
		player_hand_instances.get_or_add(pi.getPlayerUUID(), []); \
		player_maxhandsize.get_or_add(pi.getPlayerUUID(), DEFAULT_HANDSIZE))

# Called during CardPack Generation
func record_player_cardpack_options(player_uuid : String, card_packs : Array) -> void:
	cardpack_options[player_uuid] = card_packs

# Called by CardPackChooser which is found in CardPackManager
func record_cardpack_choice(player_uuid : String, cardpack_index : int) -> void:
	cardpack_options[player_uuid] = cardpack_options[player_uuid][cardpack_index]

################################# PLAYER HAND #####################################
func attempt_card_to_hand(player_uuid : String, cardset_index : int) -> Array[String]:
	var added_card_instance_ids : Array[String]
	# At this point, card_set_options should be reduced to only the cardpack the player picked.
	if cardset_index >= cardpack_options[player_uuid].size() || cardset_index < 0:
		return []
	
	# The number of cards the player can take in (due to their max hand size)
	var numcards_to_hand = player_maxhandsize[player_uuid] - player_hand_instances[player_uuid].size()
	
	if numcards_to_hand <= 0:
		return []
		
	var card_set_cards : Dictionary[String, CardInstanceData] = cardpack_options[player_uuid][cardset_index]
		
	numcards_to_hand = min(numcards_to_hand, card_set_cards.size())
	for i in range(numcards_to_hand):
		player_hand_instances[player_uuid].append(card_set_cards.values()[i])
		added_card_instance_ids.append(card_set_cards.values()[i].get_id())
	return added_card_instance_ids

func append_to_player_hand(player_uuid : String, card_set : Array[int], add_to_hand : Callable) -> bool:
	if player_hand_instances[player_uuid].size() >= player_maxhandsize[player_uuid]:
		# CARD DISCARDED
		return false
		
	#player_hand_instances[player_uuid].append(card_instance)
	return true

func search_hand_for(player_uuid : String, instance_id : String) -> CardInstanceData:
	var cards_in_hand : Array[CardInstanceData] 
	cards_in_hand.assign(player_hand_instances[player_uuid])
	for c in cards_in_hand:
		if c.get_id() == instance_id:
			return c
	return null
####################################################################################
