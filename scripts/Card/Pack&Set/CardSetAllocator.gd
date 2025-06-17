extends Object
class_name CardSetAllocator

var _cardset_options : Array[CardSetData] = []
var _create_pack : Callable

var player_picked_packs : Dictionary[int, Array]

# Right now the assumption is that every set has a "appear count" of 1
# Prolly need to make every cardsetdata unique or make a Pair<CardSetData, int> 
var avail_packs : Array[CardSetData]

var remove_prev_selected : bool

func _init(cardset_options : Array[CardSetData], create_pack : Callable) -> void:
	_cardset_options = cardset_options
	_create_pack = create_pack
	PlayerManager.forEachPlayer(func(pi : PlayerInfo) : \
		player_picked_packs.get_or_add(pi.getPlayerId(), []))
	avail_packs = _cardset_options.duplicate(false)
	NetworkManager.connect("all_clients_ready", provide_sets)
	
func get_random_set(n : int) -> Array[String]:
	var size = avail_packs.size()
	var arr : Array[String] = []
	for i in range(n):
		arr.append(avail_packs[randi() % size].get_id())
	return arr

func provide_sets() -> void:
	for player_id in player_picked_packs.keys():
		_provide_sets(player_id)
		
func _provide_sets(player_id : int) :
	var array_sets : Array[String] = get_random_set(4)
	
	# Prolly will change this eventually
	player_picked_packs[player_id].append(array_sets); 
	
	_create_pack.call(player_id, array_sets)
