extends Node

@export var card_scene : PackedScene

var card_attribute_gen : CardAttributeGenerator

@export_category("CardSet Creation")
@export var remove_used_sets := false
@export var cardset_grp : ResourceGroup
var card_set_arr : Array[CardSetData] = []

var cardset_allocator : CardSetAllocator

@export_category("BuildingCard Creation")
# BuildingData
@export var buildingcard_img : Texture2D
@export var building_grp : ResourceGroup
var buildings : Array[BuildingData] = []
var buildings_dict = {}

## Server
var server_card_memory : ServerCardMemory
var local_cardpacks_datainst_mem : Array
## NOTE: THSES ARE TEMP VARS PLEASE DONT USE THEM
var _local_cardpack_datainst_mem : Array[Dictionary]
var _local_cardset_datainst_mem : Dictionary[String, CardInstanceData]

#for constructors
var building_card_scene: PackedScene = preload("res://scenes/Card/building_card.tscn")
var aura_card_scene: PackedScene = preload("res://scenes/Card/aura_card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load all buildings data 
	building_grp.load_all_into(buildings)
	
	for b in buildings:
		if b:
			buildings_dict.get_or_add(b.get_id(), b)

	if multiplayer.is_server():
		card_attribute_gen = CardAttributeGenerator.new()
		cardset_allocator = CardSetAllocator.new(cardset_grp, remove_used_sets)
		server_card_memory = ServerCardMemory.new()
		Signalbus.connect("server_create_packs", get_cards_for_allpacks)
	#NetworkManager.mark_client_ready(self.name)

func setup() -> void:
	if multiplayer.is_server():
		cardset_allocator.setup()
		server_card_memory.setup()

#################################### CARDPACK/SET LOGIC ############################################
func get_cards_for_allpacks() -> void:
	# Card counts of every card, each element in the array is a cardset
	var cardpacks : Array[Array] = cardset_allocator.get_packs()
	var player_options_num : Dictionary[String,int] = cardset_allocator.get_player_num_options()
	
	var numstream : Array[Array] = card_attribute_gen.generate_cardpackstream(cardpacks)
	# Get attributes for cards	
	var cards_for_server = _get_cards_for_packs(cardpacks,numstream)

	Signalbus.emit_signal("server_update_chooser", cardset_allocator.get_num_packs())
	PlayerManager.forEachPlayer(func(pi : PlayerInfo): \
		print(pi.getPlayerName(), " ", pi.getPlayerId()); \
		print("PLAYER OPTIONS ", player_options_num); \
		print("CARDPACKS ", cardpacks); \
		print("NUMSTREAM ", numstream); \
		print("TRUNCATED CARDPACKS ", truncate_pack(cardpacks, player_options_num[pi.getPlayerUUID()])); \
		print("TRUNCATED NUMSTREAM ", truncate_pack(numstream, player_options_num[pi.getPlayerUUID()])); \
		var server_copy = truncate_pack(local_cardpacks_datainst_mem, player_options_num[pi.getPlayerUUID()]);\
		server_card_memory.record_player_cardpack_options(pi.getPlayerUUID(), server_copy);\
			
		if pi.getPlayerId() != 1:
			_get_cards_for_clientpack.rpc_id(pi.getPlayerId(), truncate_pack(cardpacks,player_options_num[pi.getPlayerUUID()]), \
				truncate_pack(numstream, player_options_num[pi.getPlayerUUID()]));\
		elif NetworkManager.is_server_client:\
			local_cardpacks_datainst_mem = truncate_pack(local_cardpacks_datainst_mem, server_copy);\
			Signalbus.emit_signal("create_pack", server_copy));

func truncate_pack(packs : Array[Array], truncate_size : int) -> Array[Array]:
	var truncated_pack : Array[Array] = []
	for cardpack in packs:
		truncated_pack.append(cardpack.slice(0, truncate_size))
	return truncated_pack

func _get_cards_for_packs(cardpacks : Array, attribute_numbers : Array) -> Array[Array]:
	var total_cardpacks : Array[Array] = []
	
	for pack_index in range(len(cardpacks)):		
		total_cardpacks.append(get_cards_for_pack(cardpacks[pack_index], attribute_numbers[pack_index]))
	return total_cardpacks

func get_cards_for_pack(cardpack : Array[Dictionary], attribute_numbers : Array) -> Array:
	var cardpack_out := Array()
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
			data_inst = _create_data_instance(card_type , attribute_numbers[start_count + count])
			_local_cardset_datainst_mem.get_or_add(data_inst.get_id(), data_inst)
			cardset_out.append(_create_card(data_inst))
		start_count += cardset[card_type]
	_local_cardpack_datainst_mem.append(_local_cardset_datainst_mem)
	return cardset_out

# Clients + Server run this code
# uuids : Array[int]
@rpc("any_peer","call_local")
func _get_cards_for_clientpack(cardpacks : Array, attribute_numbers : Array) -> void:
	var output : Array[Array] = _get_cards_for_packs(cardpacks, attribute_numbers)
	
	#local_cardpack_memory = output
	Signalbus.emit_signal("create_pack", output)

#func update_local_cardpack_choice(cardpack_id : int) -> void:
	#local_cardpack_memory = local_cardpack_memory[cardpack_id]

################################## CARD CREATION LOGIC #######################################

func _create_data_instance(data_id : String, attribute_number : int = 0) -> CardInstanceData:
	if attribute_number == -1:
		attribute_number = card_attribute_gen.generate_random_attribute()
	
	# Add more to this dict for diff types of card-datas
	var data : CardData = buildings_dict.get(data_id, null)
	
	if data is BuildingData:
		return BuildingInstanceData.new(data as BuildingData, attribute_number)
	else:
		return null

# Add to scene must be done by manually by node calling this method
func _create_card(data : CardInstanceData) -> Card:
	var card : Card
	if data is BuildingInstanceData:
		card = card_scene.instantiate()
		card.set_up(data, buildingcard_img)
		return card
	return null

################################### ADDING TO HAND #################################################

@rpc("any_peer","call_local")
func attempt_add_to_hand(set_id : int) -> void:
	var remote_id := multiplayer.get_remote_sender_id()
	
	var ids : Array[String] = server_card_memory.attempt_card_to_hand( \
		PlayerManager.getUUID_from_PeerID(remote_id), set_id)
	
	_add_to_hand.rpc_id(remote_id, ids, set_id)

@rpc("any_peer","call_local")
func _add_to_hand(card_instance_ids : Array[String], set_id : int) -> void:
	Signalbus.emit_signal("cards_frm_set_to_hand", card_instance_ids, set_id)
	#var output : Array[Card]
	#for card in local_cardpack_memory[set_id]:
		#if card.get_data_instance_id() in card_instance_ids:
			#output.append(card)
#
	#
	#Signalbus.emit_signal("add_to_player_hand", output)

func get_building_data(id : String) -> BuildingData:
	return buildings_dict.get(id)

func get_card_data(id : String) -> CardData:
	return buildings_dict.get(id)

func get_display_name(id : String) -> String:
	return buildings_dict.get(id).display_name

func get_texture(id : String) -> Texture2D:
	return buildings_dict.get(id).card_sprite


#func get_random_set(n : int) -> Array[CardSetData]:
	#var size = cardset_types.size()
	#var arr : Array[CardSetData] = []
	#for i in range(n):
		#arr.append(cardset_types[randi() % size])
	#return arr
