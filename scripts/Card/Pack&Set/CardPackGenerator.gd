extends Node
class_name CardPackGenerator

@export_category("CardSet Creation")
@export var remove_used_sets := false
@export var cardset_grp : ResourceGroup
var card_set_arr : Array[CardSetData] = []

var cardset_allocator : CardSetAllocator
var card_attribute_gen : CardAttributeGenerator
var server_card_memory : ServerCardMemory

var local_cardpacks_datainst_mem : Array[Array]
## NOTE: THSES ARE TEMP VARS PLEASE DONT USE THEM
var _local_cardpack_datainst_mem : Array[Dictionary]
var _local_cardset_datainst_mem : Dictionary[String, CardInstanceData]

var create_data_inst : Callable
var create_card : Callable

func _ready() -> void:
	if multiplayer.is_server():
		Signalbus.connect("server_create_packs", server_generate_packs)

func server_setup(attr_gen : CardAttributeGenerator, server_mem : ServerCardMemory, cardset_alloc : CardSetAllocator = null) -> void:
	card_attribute_gen = attr_gen
	server_card_memory = server_mem
	if cardset_alloc == null:
		cardset_allocator = CardSetAllocator.new(cardset_grp, remove_used_sets)
		cardset_allocator.setup()
	else:
		cardset_allocator = cardset_alloc
		
	
	pass

func setup(create_data_inst : Callable, create_card : Callable) -> void:
	self.create_data_inst = create_data_inst
	self.create_card = create_card

#################################### CARDPACK/SET LOGIC ############################################
func server_generate_packs() -> void:
	# Card counts of every card, each element in the array is a cardset
	var cardpacks : Array[Array] = cardset_allocator.get_packs()
	var player_options_num : Dictionary[String,int] = cardset_allocator.get_player_num_options()
	
	var numstream : Array[Array] = card_attribute_gen.generate_cardpackstream(cardpacks)
	# Get attributes for cards	
	var cards_for_server = get_cards_for_allpacks(cardpacks,numstream)
	
	var server_copy_of_player_options : Array
	Signalbus.emit_signal("server_update_chooser", cardset_allocator.get_num_packs())
	PlayerManager.forEachPlayer(func(pi : PlayerInfo): \
		#print(pi.getPlayerName(), " ", pi.getPlayerId()); \
		#print("PLAYER OPTIONS ", player_options_num); \
		#print("CARDPACKS ", cardpacks); \
		#print("NUMSTREAM ", numstream); \
		#print("TRUNCATED CARDPACKS ", truncate_pack(cardpacks, player_options_num[pi.getPlayerUUID()])); \
		#print("TRUNCATED NUMSTREAM ", truncate_pack(numstream, player_options_num[pi.getPlayerUUID()])); \
		
		# FOR SERVER's MEMORY 
		server_copy_of_player_options = truncate_pack(local_cardpacks_datainst_mem, player_options_num[pi.getPlayerUUID()]);\
		server_card_memory.record_player_cardpack_options(pi.getPlayerUUID(), server_copy_of_player_options);\
			
		# ACTUAL CARD CREATION AND LOCAL MEMORY STORAGE FOR CLIENTS
		if pi.getPlayerId() != 1:
			get_cards_for_clientpack.rpc_id(pi.getPlayerId(), truncate_pack(cardpacks,player_options_num[pi.getPlayerUUID()]), \
				truncate_pack(numstream, player_options_num[pi.getPlayerUUID()]));\
		elif NetworkManager.is_server_client:\
			local_cardpacks_datainst_mem = truncate_pack(local_cardpacks_datainst_mem, player_options_num[pi.getPlayerUUID()]);\
			Signalbus.emit_signal("create_pack", truncate_pack(cards_for_server, player_options_num[pi.getPlayerUUID()])));

# Clients + Server run this code
# uuids : Array[int]
@rpc("any_peer","call_local")
func get_cards_for_clientpack(cardpacks : Array, attribute_numbers : Array) -> void:
	var output : Array[Array] = get_cards_for_allpacks(cardpacks, attribute_numbers)
	Signalbus.emit_signal("create_pack", output)

func truncate_pack(packs : Array[Array], truncate_size : int) -> Array[Array]:
	var truncated_pack : Array[Array] = []
	for cardpack in packs:
		truncated_pack.append(cardpack.slice(0, truncate_size))
	return truncated_pack

func get_cards_for_allpacks(cardpacks : Array, attribute_numbers : Array) -> Array[Array]:
	reset_local_mem()
	var total_cardpacks : Array[Array] = []
	
	for pack_index in range(len(cardpacks)):		
		total_cardpacks.append(get_cards_for_pack(cardpacks[pack_index], attribute_numbers[pack_index]))
	return total_cardpacks

func get_cards_for_pack(cardpack : Array[Dictionary], attribute_numbers : Array) -> Array:
	var cardpack_out := Array()
	_local_cardpack_datainst_mem = []
	for cardset_index in range(len(cardpack)):
		cardpack_out.append(get_cards_for_set(cardpack[cardset_index] as Dictionary[String,int], attribute_numbers[cardset_index]))
	local_cardpacks_datainst_mem.append(_local_cardpack_datainst_mem)
	return cardpack_out

func get_cards_for_set(cardset : Dictionary[String, int], attribute_numbers : Array) -> Array:
	var start_count := 0
	var cardset_out := Array()
	var data_inst : CardInstanceData
	var card_types : Array[String] = cardset.keys()
	_local_cardset_datainst_mem = {}
	
	for card_type in card_types:
		for count in range(cardset[card_type]):
			
			# Data instance creation and storing
			data_inst = create_data_inst.call(card_type , attribute_numbers[start_count + count])
			_local_cardset_datainst_mem.get_or_add(data_inst.get_id(), data_inst)
			
			# Actual Card UI Creation
			cardset_out.append(create_card.call(data_inst))	
		start_count += cardset[card_type]
		
	_local_cardpack_datainst_mem.append(_local_cardset_datainst_mem)
	return cardset_out

func reset_local_mem() -> void:
	local_cardpacks_datainst_mem = []
	_local_cardpack_datainst_mem = []
	_local_cardset_datainst_mem = {}

@rpc("any_peer","call_local")
func update_local_cardpack_choice(cardpack_id : int) -> void:
	_local_cardpack_datainst_mem = local_cardpacks_datainst_mem[cardpack_id]
