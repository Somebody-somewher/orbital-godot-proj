extends Object
class_name ServerCardManager
# Contain the instances of CardDataInstance

var card_count : int = 0 

# Actual Card instances created/presented for each player 
var card_set_options : Dictionary[String, Array]
var player_hand_instances : Dictionary[String, Array]

func store_player_cardpack_options(player_uuid : String, card_packs : Array) -> void:
	player_hand_instances.get_or_add(player_uuid, card_packs)
