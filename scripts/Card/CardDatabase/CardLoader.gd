extends Node
# https://github.com/derkork/godot-resource-groups

var card_attribute_gen : CardAttributeGenerator

@export_category("BuildingCard Creation")

# BuildingData
@export var building_grp : ResourceGroup
var buildings : Array[BuildingData] = []
var buildings_dict = {}

# Provided by CardPackManager
var create_pack : Callable

var server_card_memory : ServerCardManager

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
	#NetworkManager.mark_client_ready(self.name)

func setup_pack_creator(c : Callable) -> void:
	create_pack = c

# Called by CardPack to obtain data for each Cardset 
func get_cards_for_pack(cardpacks : Array[Array], player_options_num : Dictionary[String, int]) -> void:
	# Get card_set allocated to player
	var remote_sender : int = multiplayer.get_remote_sender_id()
	
	# Card counts of every card, each element in the array is a cardset
	var numstream : Array = card_attribute_gen.generate_cardpackstream(cardpacks)

	# Get attributes for cards
	var total_count : int = 0
	PlayerManager.forEachPlayer(func(pi : PlayerInfo): \
		_get_cards_for_pack.rpc(pi.getPlayerId(), truncate_pack(cardpacks,player_options_num[pi.getPlayerUUID()]), \
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
	var output :  = []
	var cardpack_out : Array = []
	var cardset_out : Array = []
	
	for pack in range(len(cardpacks)):
		cardpack_out = Array()
		for cset in range(len(cardpacks[pack])):
			cardset_out = Array()
			for card in range(len(cardpacks[pack][cset].keys())):
				for count in range(cardpacks[pack][cset][cardpacks[pack][cset].keys()[card]]):
					cardset_out.append(create_card_instance(cardpacks[pack][cset].keys()[card] \
						, attribute_numbers[pack][cset][count]))
			cardpack_out.append(cardset_out)
		output.append(cardpack_out)

	if multiplayer.is_server():
		var remote_uuid = PlayerManager.getUUID_from_PeerID(multiplayer.get_remote_sender_id())
		server_card_memory.store_player_cardpack_options(remote_uuid,cardpacks)
	
	if NetworkManager.is_client():
		create_pack.call(cardpacks)

func create_card_instance(data_id : int, attribute_number : int) -> CardInstanceData:
	# Add more to this dict for diff types of card-datas
	var data : CardData = buildings_dict.get(data_id, null)
	
	if data is BuildingData:
		return BuildingInstanceData.new(data as BuildingData, attribute_number)
	else:
		return null

func create_building_card(building_id : String) -> BuildingCard:
	return 

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
