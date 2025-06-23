extends Node

@export var card_scene : PackedScene

var card_attribute_gen : CardAttributeGenerator

@export_category("BuildingCard Creation")
# BuildingData
@export var buildingcard_img : Texture2D
@export var building_grp : ResourceGroup
var buildings : Array[BuildingData] = []
var buildings_dict = {}

# Provided by CardPackManager
var create_pack : Callable
var add_to_hand : Callable


var local_cardpack_memory : Array
## Server
var server_card_memory : ServerCardMemory

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
		server_card_memory = ServerCardMemory.new()
	#NetworkManager.mark_client_ready(self.name)



#################################### CARDPACK/SET LOGIC ############################################
# Called by CardPack to obtain data for each Cardset 
func setup_pack_creator(c : Callable) -> void:
	create_pack = c
	
func get_cards_for_pack(cardpacks : Array[Array], player_options_num : Dictionary[String, int]) -> void:
	# Card counts of every card, each element in the array is a cardset
	var numstream : Array[Array] = card_attribute_gen.generate_cardpackstream(cardpacks)
	# Get attributes for cards
	var total_count : int = 0
	PlayerManager.forEachPlayer(func(pi : PlayerInfo): \
		#print(pi.getPlayerName(), " ", pi.getPlayerId()); \
		#print("PLAYER OPTIONS ", player_options_num); \
		#print("CARDPACKS ", cardpacks); \
		#print("NUMSTREAM ", numstream); \
		#print("TRUNCATED CARDPACKS ", truncate_pack(cardpacks, player_options_num[pi.getPlayerUUID()])); \
		#print("TRUNCATED NUMSTREAM ", truncate_pack(numstream, player_options_num[pi.getPlayerUUID()])); \
		_get_cards_for_pack.rpc_id(pi.getPlayerId(), truncate_pack(cardpacks,player_options_num[pi.getPlayerUUID()]), \
			truncate_pack(numstream, player_options_num[pi.getPlayerUUID()])))

func truncate_pack(packs : Array[Array], truncate_size : int) -> Array[Array]:
	var truncated_pack : Array[Array] = []
	for cardpack in packs:
		truncated_pack.append(cardpack.slice(0, truncate_size))
	return truncated_pack

# Clients + Server run this code
# uuids : Array[int]
@rpc("any_peer","call_local")
func _get_cards_for_pack(cardpacks : Array, attribute_numbers : Array) -> void:
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

	if multiplayer.is_server():
		var remote_uuid = PlayerManager.getUUID_from_PeerID(multiplayer.get_remote_sender_id())
		server_card_memory.record_player_cardpack_options(remote_uuid,output)
	
	if NetworkManager.is_client():
		local_cardpack_memory = output
		create_pack.call(output)

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

func create_building_card(building_id : String) -> BuildingCard:
	return 

####################################################################################################

################################### ADDING TO HAND #################################################

func setup_add_to_hand(c : Callable) -> void:
	add_to_hand = c

func attempt_add_to_hand(set_id : int) -> void:
	server_card_memory.attempt_card_to_hand()
	
#func approved_add_to_hand(cardinstance_id : Array[String]) -> void:
	

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
