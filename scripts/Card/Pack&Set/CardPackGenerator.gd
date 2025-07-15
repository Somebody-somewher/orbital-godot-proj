extends Node
class_name CardPackGenerator

@export_category("CardSet Creation")
@export var remove_used_sets := false
@export var cardset_grp : ResourceGroup

var cardset_allocator : CardSetAllocator
var card_attribute_gen : CardAttributeGenerator
var card_memory : CardMemory

var local_cardpacks_datainst_mem : Dictionary[int, Dictionary]
## NOTE: THSES ARE TEMP VARS PLEASE DONT USE THEM
var _local_cardpack_datainst_mem : Dictionary[String,Dictionary]
var _local_cardset_datainst_mem : Dictionary[String, CardInstanceData]

var create_data_inst : Callable
var create_card : Callable
var update_chosen_cardpack : Callable

func _ready() -> void:
	if multiplayer.is_server():
		Signalbus.connect("server_create_packs", server_generate_packs)

func server_setup(attr_gen : CardAttributeGenerator, cardset_alloc : CardSetAllocator = null) -> void:
	card_attribute_gen = attr_gen
	if cardset_alloc == null:
		cardset_allocator = CardSetAllocator.new(cardset_grp, remove_used_sets)
		cardset_allocator.setup()
	else:
		cardset_allocator = cardset_alloc
		
	pass

func setup(card_memory : CardMemory, create_data_inst : Callable, create_card : Callable) -> void:
	self.card_memory = card_memory
	self.create_data_inst = create_data_inst
	self.create_card = create_card
	

#################################### CARDPACK/SET LOGIC ############################################
func server_generate_packs() -> void:
	
	# This is a Dictionary nested in 3 layers
	# Dictionary[int, Dictionary] -> Each pack has an id
	# Dictionary[String, Dictionary] -> Each set has a string id too
	# Dictionary[String, int] -> Each card has a set quantity
	var cardpacks : Dictionary[int, Dictionary] = cardset_allocator.get_packs()	
	var player_options_num : Dictionary[String,int] = cardset_allocator.get_player_num_options()
	
	# Get attributes for cards. This is a Dictionary nested in 3 layers
	# Dictionary[int, Dictionary] -> Each pack has an id
	# Dictionary[String, Array] -> Each set has a stream of cards attributes
	# Array[Array] -> Each card has a unique_id and a unique numerical attribute
	var numstream : Dictionary[int, Dictionary] = card_attribute_gen.generate_cardpackstream(cardpacks)
	var cards_for_server = get_cards_for_allpacks(cardpacks,numstream)
	var server_copy_of_player_options : Dictionary
	Signalbus.emit_signal("server_update_chooser", cardpacks.keys())
	PlayerManager.forEachPlayer(func(pi : PlayerInfo): \
		#print(pi.getPlayerName(), " ", pi.getPlayerId()); \
		#print("PLAYER OPTIONS ", player_options_num); \
		#print("CARDPACKS ", cardpacks); \
		#print("NUMSTREAM ", numstream); \
		#print("TRUNCATED CARDPACKS ", truncate_pack(cardpacks, player_options_num[pi.getPlayerUUID()])); \
		#print("TRUNCATED NUMSTREAM ", truncate_pack(numstream, player_options_num[pi.getPlayerUUID()])); \
		
		# FOR SERVER's MEMORY
		var server_card_mem = (card_memory as ServerCardMemory);\
		server_card_mem.server_record_player_cardpack_options(\
			_truncate_pack(local_cardpacks_datainst_mem, player_options_num[pi.getPlayerUUID()]), pi.getPlayerUUID());\
		
		# ACTUAL CARD CREATION AND LOCAL MEMORY STORAGE FOR CLIENTS
		if pi.getPlayerId() != 1:
			get_cards_for_clientpack.rpc_id(pi.getPlayerId(), _truncate_pack(cardpacks,player_options_num[pi.getPlayerUUID()]), \
				_truncate_pack(numstream, player_options_num[pi.getPlayerUUID()])));
	
	if NetworkManager.is_server_client:
		#card_memory.record_player_cardpack_options(local_cardpacks_datainst_mem)
		Signalbus.emit_signal("create_pack", _truncate_pack(cards_for_server, player_options_num[PlayerManager.getUUID_from_PeerID(1)]))


# Clients + Server run this code
# uuids : Array[int]
@rpc("any_peer","call_local")
func get_cards_for_clientpack(cardpacks : Dictionary[int,Dictionary], attribute_numbers : Dictionary[int,Dictionary]) -> void:
	var output : Dictionary[int,Dictionary] = get_cards_for_allpacks(cardpacks, attribute_numbers)
	card_memory.record_player_cardpack_options(local_cardpacks_datainst_mem)
	Signalbus.emit_signal("create_pack", output)

func _truncate_pack(packs : Dictionary[int,Dictionary], truncate_size : int) -> Dictionary[int, Dictionary]:
	var truncated_pack : Dictionary[int, Dictionary] = {}
	for cardpack_id in packs.keys():
		truncated_pack[cardpack_id] = _slice_cardset_in_cardpack(packs[cardpack_id], truncate_size)
	return truncated_pack

func _slice_cardset_in_cardpack(cardpack : Dictionary, truncate_size : int) -> Dictionary:
	var count = 0
	var sliced_pack : Dictionary
	var keys := cardpack.keys()
		
	while count < truncate_size:
		sliced_pack[keys[count]] = cardpack[keys[count]]
		count += 1
	
	return sliced_pack

func truncate_nums_for_pack(packs : Array[Array], truncate_size : int) -> Array[Array]:
	var truncated_pack : Array[Array] = []
	for cardpack in packs:
		truncated_pack.append(cardpack.slice(0, truncate_size))
	return truncated_pack

func get_cards_for_allpacks(cardpacks : Dictionary[int, Dictionary], attribute_numbers : Dictionary[int, Dictionary]) -> Dictionary[int,Dictionary]:
	reset_temp_mem()
	var total_cardpacks : Dictionary[int, Dictionary] = {}
	var cardsets_in_pack : Dictionary[String, Dictionary]
	for pack_id in cardpacks.keys():
		total_cardpacks[pack_id] = get_cards_for_pack(cardpacks[pack_id], attribute_numbers[pack_id])
		local_cardpacks_datainst_mem[pack_id] = _local_cardpack_datainst_mem.duplicate(true)
	return total_cardpacks

# func get_cards_for_pack(cardpack : Dictionary[String, Dictionary], attribute_numbers : Dictionary[String, Array]) -> Dictionary[String, Array]:
func get_cards_for_pack(cardpack : Dictionary, attribute_numbers : Dictionary) -> Dictionary:
	var cardpack_out : Dictionary
	_local_cardpack_datainst_mem = {}
	for cardset_id in cardpack.keys():
		cardpack_out[cardset_id] = get_cards_for_set(cardpack[cardset_id], attribute_numbers[cardset_id])
		_local_cardpack_datainst_mem[cardset_id] = _local_cardset_datainst_mem.duplicate(true)
	return cardpack_out

# get_cards_for_set(cardset : Dictionary[String, int], attribute_numbers : Array[Array]) -> Array[Card]:
func get_cards_for_set(cardset : Dictionary, attribute_numbers : Array) -> Array[Card]:
	var start_count := 0
	var cardset_out : Array[Card]
	var data_inst : CardInstanceData
	var card_types : Array[String] = cardset.keys()
	_local_cardset_datainst_mem = {}
	
	for card_type in card_types:
		for count in range(cardset[card_type]):
			
			# Data instance creation and storing
			data_inst = create_data_inst.call(card_type, attribute_numbers[start_count + count][1], attribute_numbers[start_count + count][0])
			_local_cardset_datainst_mem[data_inst.get_id()] = data_inst
			
			# Actual Card UI Creation
			if !multiplayer.is_server() or NetworkManager.is_server_client:
				cardset_out.append(create_card.call(data_inst))	
				
		start_count += cardset[card_type]
		
	return cardset_out

func reset_temp_mem() -> void:
	local_cardpacks_datainst_mem = {}
	_local_cardpack_datainst_mem = {}
	_local_cardset_datainst_mem = {}
	
func reset() -> void:
	reset_temp_mem()
	cardset_allocator = null
	card_attribute_gen = null
	card_memory = null
	
