extends Object
class_name CardSetAllocator

var cardset_options : Array[CardSetData] = []

const DEFAULT_NUM_OPTIONS = 2
const MAX_OPTIONS_PER_PACK = 4

var num_packs_to_gen

var num_options_per_player : Dictionary[String, int]

# Right now the assumption is that every set has a "appear count" of 1
# Prolly need to make every cardsetdata unique or make a Pair<CardSetData, int> 
var avail_sets : Dictionary[String, CardSetData] = {}
var avail_set_count : Dictionary[String, int] = {}

#NOTE NOT IMPLEMENTED
var remove_prev_selected := false

func _init(sets_grp : ResourceGroup, remove_prev : bool) -> void:
	remove_prev_selected = remove_prev
	sets_grp.load_all_into(cardset_options)
	
	for cardset in cardset_options:
		if cardset:
			avail_sets.get_or_add(cardset.get_id(), cardset)

func setup() -> void:		
	PlayerManager.forEachPlayer(func(pi : PlayerInfo) : \
		num_options_per_player.get_or_add(pi.getPlayerUUID(), DEFAULT_NUM_OPTIONS))
	
	num_packs_to_gen = PlayerManager.getNumPlayers()
	
func get_random_set(n : int) -> Array[CardSetData]:
	var size = avail_sets.size()
	var arr : Array[CardSetData]
	for i in range(n):
		arr.append(avail_sets[avail_sets.keys()[randi() % size]])
	return arr

# This returns an Array of CardData ids
func get_sets() -> Array[Dictionary]:
	var max_options = DEFAULT_NUM_OPTIONS
	for player in num_options_per_player.keys():
		max_options = max(max_options, num_options_per_player[player])
	
	var cardsets : Array[CardSetData] = get_random_set(max_options)
	
	# Card counts of every card, each element in the array is a cardset
	var output : Array[Dictionary] = []
	for cardset in cardsets:
		output.append(cardset.cards)
	return output

func get_packs() -> Array[Array]:
	var output : Array[Array] = []
	
	for count in range(num_packs_to_gen):
		output.append(get_sets())
	
	return output

func get_player_num_options() -> Dictionary[String,int]:
	return num_options_per_player

func update_set_used(set_id : String) -> void:
	if remove_prev_selected:
		avail_sets.erase(set_id)

func update_num_options_for_player(uuid : String, modifier : int) -> void:
	num_options_per_player[uuid] = clampi(num_options_per_player[uuid] + modifier, 1, MAX_OPTIONS_PER_PACK)

func get_num_packs() -> int:
	return num_packs_to_gen

func get_all_sets_as_dicts() -> Array[Dictionary]:
	var output : Array[Dictionary]
	for cardset_data in cardset_options:
		output.append(cardset_data.cards)
	return output
