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
#var local_cardpack_memory : Array

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
		Signalbus.connect("server_create_packs", get_cards_for_pack)
	#NetworkManager.mark_client_ready(self.name)

func setup() -> void:
	if multiplayer.is_server():
		cardset_allocator.setup()
		server_card_memory.setup()

#################################### CARDPACK/SET LOGIC ############################################
func get_cards_for_pack() -> void:
	# Card counts of every card, each element in the array is a cardset
	var cardpacks : Array[Array] = cardset_allocator.get_packs()
	var player_options_num : Dictionary[String,int] = cardset_allocator.get_player_num_options()
	
	var numstream : Array[Array] = card_attribute_gen.generate_cardpackstream(cardpacks)
	# Get attributes for cards	
	var cards_for_server = _get_cards_for_pack(cardpacks,numstream)

	Signalbus.emit_signal("server_update_chooser", cardset_allocator.get_num_packs())
	PlayerManager.forEachPlayer(func(pi : PlayerInfo): \
		#print(pi.getPlayerName(), " ", pi.getPlayerId()); \
		#print("PLAYER OPTIONS ", player_options_num); \
		#print("CARDPACKS ", cardpacks); \
		#print("NUMSTREAM ", numstream); \
		#print("TRUNCATED CARDPACKS ", truncate_pack(cardpacks, player_options_num[pi.getPlayerUUID()])); \
		#print("TRUNCATED NUMSTREAM ", truncate_pack(numstream, player_options_num[pi.getPlayerUUID()])); \
		var server_copy = truncate_pack(cards_for_server,player_options_num[pi.getPlayerUUID()]);\
		server_card_memory.record_player_cardpack_options(pi.getPlayerUUID(), server_copy);\
			
		if pi.getPlayerId() != 1:
			_get_cards_for_clientpack.rpc_id(pi.getPlayerId(), truncate_pack(cardpacks,player_options_num[pi.getPlayerUUID()]), \
				truncate_pack(numstream, player_options_num[pi.getPlayerUUID()]));\
		elif NetworkManager.is_server_client:\
			#local_cardpack_memory = server_copy;\
			Signalbus.emit_signal("create_pack", server_copy));

func truncate_pack(packs : Array[Array], truncate_size : int) -> Array[Array]:
	var truncated_pack : Array[Array] = []
	for cardpack in packs:
		truncated_pack.append(cardpack.slice(0, truncate_size))
	return truncated_pack

func _get_cards_for_pack(cardpacks : Array, attribute_numbers : Array) -> Array[Array]:
	var output : Array[Array] = []
	var cardpack_out : Array = []
	var cardset_out : Array = []
	
	for pack in range(len(cardpacks)):
		cardpack_out = Array()
		for cset in range(len(cardpacks[pack])):
			cardset_out = Array()
			for card in range(len(cardpacks[pack][cset].keys())):
				for count in range(cardpacks[pack][cset][cardpacks[pack][cset].keys()[card]]):
					cardset_out.append(create_card(cardpacks[pack][cset].keys()[card] \
						, attribute_numbers[pack][cset][count]))
			cardpack_out.append(cardset_out)
		output.append(cardpack_out)
	return output

# Clients + Server run this code
# uuids : Array[int]
@rpc("any_peer","call_local")
func _get_cards_for_clientpack(cardpacks : Array, attribute_numbers : Array) -> void:
	var output : Array[Array] = _get_cards_for_pack(cardpacks, attribute_numbers)
	
	#local_cardpack_memory = output
	Signalbus.emit_signal("create_pack", output)

#func update_local_cardpack_choice(cardpack_id : int) -> void:
	#local_cardpack_memory = local_cardpack_memory[cardpack_id]

################################## CARD CREATION LOGIC #######################################

func create_data_instance(data_id : String, attribute_number : int = 0) -> CardInstanceData:
	if attribute_number == -1:
		attribute_number = card_attribute_gen.generate_random_attribute()
	
	# Add more to this dict for diff types of card-datas
	var data : CardData = buildings_dict.get(data_id, null)
	
	if data is BuildingData:
		return BuildingInstanceData.new(data as BuildingData, attribute_number)
	else:
		return null

# Add to scene must be done by manually by node calling this method
@rpc("any_peer","call_local")
func create_card(data_id : String, attribute_number : int = 0) -> Card:
	var data_instance : CardInstanceData
	var card : Card
	data_instance = create_data_instance(data_id, attribute_number)
	if data_instance is BuildingInstanceData:
		card = card_scene.instantiate()
		card.set_up(data_instance, buildingcard_img)
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
