extends Object
class_name ServerCardMemory
# Contain the instances of CardDataInstance

var card_count : int = 0 

# Actual Card instances created/presented for each player 
var card_set_options : Dictionary[String, Array] = {}

var player_hand_instances : Dictionary[String, Array] = {}
var player_maxhandsize : Dictionary[String, int] = {}
var DEFAULT_HANDSIZE := 10

func _init() -> void:
	PlayerManager.forEachPlayer(func(pi : PlayerInfo): \
		card_set_options.get_or_add(pi.getPlayerUUID(), []); \
		player_hand_instances.get_or_add(pi.getPlayerUUID(), []); \
		player_maxhandsize.get_or_add(pi.getPlayerUUID(), DEFAULT_HANDSIZE))

func store_player_cardpack_options(player_uuid : String, card_packs : Array) -> void:
	card_set_options.get_or_add(player_uuid, card_packs)

func select_cardpack(player_uuid : String, cardpack_id : int) -> bool:
	card_set_options[player_uuid] = card_set_options[player_uuid][cardpack_id]
	return true

## TODO: Eventually need to remove cardpack_id. We 
func append_to_player_hand(player_uuid : String, card_instance_id : int, card_set : int) -> bool:
	if player_hand_instances[player_uuid].size() >= player_maxhandsize[player_uuid]:
		# CARD DISCARDED
		return false
		
	#player_hand_instances[player_uuid].append(card_instance)
	return true
	
