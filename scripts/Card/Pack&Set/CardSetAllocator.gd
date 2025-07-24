extends Object
class_name CardSetAllocator



const DEFAULT_NUM_OPTIONS = 2
const MAX_OPTIONS_PER_PACK = 4
var num_packs_to_gen : int
var num_options_per_player : Dictionary[String, int]

var rng : RandomNumberGenerator
var cardset_creation_count := 0

var is_debug := false 

var num_packs_generated := 0

# Right now the assumption is that every set has a "appear count" of 1
# Prolly need to make every cardsetdata unique or make a Pair<CardSetData, int> 
var avail_sets : Dictionary[String, CardSetData] = {}
var loaded_card_sets : Dictionary[String, CardSetData] = {}
var avail_set_count : Dictionary[String, int] = {}

#NOTE NOT IMPLEMENTED
var remove_prev_selected := false

func _init(sets_grp : ResourceGroup, remove_prev := false, seed := -1) -> void:
	remove_prev_selected = remove_prev
	
	var cardset_options : Array[CardSetData] = []
	sets_grp.load_all_into(cardset_options)
	
	for cardset in cardset_options:
		if cardset:
			loaded_card_sets.get_or_add(cardset.get_id(), cardset)
	
	rng = RandomNumberGenerator.new()
	if seed == -1:
		rng.randomize()
	else:
		rng.set_seed(seed)

func debug_setup(cardset_ids : Array[String], num_options := DEFAULT_NUM_OPTIONS) -> void:
	is_debug = true
	setup(num_options)
	
	for id in cardset_ids:
		avail_sets.get_or_add(id, loaded_card_sets[id])

func setup(num_options := DEFAULT_NUM_OPTIONS) -> void:		
	PlayerManager.forEachPlayer(func(pi : PlayerInfo) : \
		num_options_per_player.get_or_add(pi.getPlayerUUID(), num_options))
	
	num_packs_to_gen = PlayerManager.getNumPlayers()
	
	if !is_debug:
		avail_sets = loaded_card_sets.duplicate(true)

func get_packs() -> Dictionary[int, Dictionary]:
	var output : Dictionary[int, Dictionary] = {}
	
	for count in range(num_packs_to_gen):
		output[num_packs_generated] = get_sets()
		num_packs_generated += 1
	
	return output

############################### SET FUNCTIONALITY ####################################
# This returns an Array of CardData ids
func get_sets() -> Dictionary[String, Dictionary]:
	var max_options = DEFAULT_NUM_OPTIONS
	for player in num_options_per_player.keys():
		max_options = max(max_options, num_options_per_player[player])
	
	var cardsets : Dictionary[String, CardSetData] = get_set(max_options)
	var output : Dictionary[String, Dictionary]
	
	for cardset_name in cardsets.keys():
		output[cardset_name] = cardsets[cardset_name].cards
		
	return output

func get_set(n : int) -> Dictionary[String, CardSetData]:
	if is_debug:
		return get_fixed_set_asc(n)
	else:
		return get_random_set(n)

func get_random_set(n : int) -> Dictionary[String, CardSetData]:
	var size
	var output : Dictionary[String, CardSetData]
	var set_name : String
	var buffer_set_name : String

	for i in range(n):
		size = avail_sets.size()
		set_name = avail_sets.keys()[rng.randi() % size]
		if set_name in output:
			buffer_set_name = set_name + "1"
		else:
			buffer_set_name = set_name
		output[buffer_set_name] = avail_sets[set_name]
	return output

func get_fixed_set_asc(n : int) -> Dictionary[String, CardSetData]:
	var size = avail_sets.size()
	var output : Dictionary[String, CardSetData]
	var set_name : String
	for i in range(n):
		set_name = avail_sets.keys()[cardset_creation_count % size]
		output[set_name] = avail_sets[set_name]
		cardset_creation_count += 1
	return output

func get_all_sets_as_dicts() -> Dictionary[String, Dictionary]:
	var output : Dictionary[String, Dictionary]
	for cardset_data in loaded_card_sets.values():
		output[cardset_data.set_name] = cardset_data.cards
	return output

############################### MISC FUNCTIONALITY ####################################

func get_player_num_options() -> Dictionary[String,int]:
	return num_options_per_player

func update_set_used(set_id : String) -> void:
	if remove_prev_selected:
		avail_sets.erase(set_id)

func update_num_options_for_player(uuid : String, modifier : int) -> void:
	num_options_per_player[uuid] = clampi(num_options_per_player[uuid] + modifier, 1, MAX_OPTIONS_PER_PACK)

func get_num_packs() -> int:
	return num_packs_to_gen
