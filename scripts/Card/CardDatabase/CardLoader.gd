extends Node

@export var card_scene : PackedScene


@export_category("BuildingCard Creation")
# BuildingData
@export var buildingcard_img : Texture2D
@export var building_grp : ResourceGroup
var buildings : Array[BuildingData] = []
var buildings_dict = {}

## Server
var card_attribute_gen : CardAttributeGenerator
var server_card_memory : ServerCardMemory
@onready var cardpack_gen : CardPackGenerator = $CardPackGen

# Packid linked to Cardset and Cards
# TODO: NEED TO CHANGE TO THIS SYSTEM
var local_pack_mem : Dictionary[int, Array]
var local_player_hand : Array[CardInstanceData]

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
		server_card_memory = ServerCardMemory.new()
	#NetworkManager.mark_client_ready(self.name)

## This is here because some things need to wait for NetworkManager or PlayerManager to setup before firing
## Run via GameManager in actual game
func setup(cag : CardAttributeGenerator = null, csa : CardSetAllocator = null) -> void:
	if multiplayer.is_server():	
		server_card_memory.setup()
		
		if cag == null:
			card_attribute_gen = CardAttributeGenerator.new()
		else:
			card_attribute_gen = cag

		cardpack_gen.server_setup(card_attribute_gen, server_card_memory, csa)
	cardpack_gen.setup(create_data_instance, create_card, func(selected_pack : Array[Dictionary], pack_id : int):\
		local_pack_mem.get_or_add(pack_id, selected_pack))


################################## CARD CREATION LOGIC #######################################

# Whoever calls this function is in charge of storing the data_instance so we can refer to it later
@rpc("any_peer", "call_local")
func create_data_instance(data_id : String, attribute_number : int = 0) -> CardInstanceData:
	
	# NOTE: IF THE CLIENT IS CALLING THIS FUNCTION, ATTRIBUTE NUMBER NOT BE -1
	# EITHER PUT IT AS 0 OR THE ATTRIBUTE NUMBER THAT CREATED THE CARD
	if attribute_number == -1:
		attribute_number = card_attribute_gen.generate_random_attribute()
	
	# Add more to this dict for diff types of card-datas
	var data : CardData = buildings_dict.get(data_id, null)
	var instance_data : CardInstanceData 
	
	if data is BuildingData:
		instance_data =  BuildingInstanceData.new(data as BuildingData, attribute_number)
	else:
		instance_data = null
	
	# THIS CODE TRIGGERS IN SERVER WHEN PACK IS CHOSEN AND CONFIRMED
	# if NetworkManager.isclient():
	#	modify(instance_data) for e.g. if there is an aura that makes 	
	
	return instance_data

# Add to scene must be done by manually by node calling this method
func create_card(data : CardInstanceData) -> Card:
	var card : Card
	if data is BuildingInstanceData:
		card = card_scene.instantiate()
		card.set_up(data, buildingcard_img)
		return card
	return null

func client_modify(player_uuid : String, data : CardInstanceData) -> void:
	# AuraManager 
	pass
	
func duplicate_cardinstance(data : CardInstanceData) -> CardInstanceData:
	if data is BuildingInstanceData:
		return BuildingInstanceData.duplicate(data)
	return null

################################### ADDING TO HAND #################################################

@rpc("any_peer","call_local")
func attempt_add_to_hand(set_index : int, pack_id : int) -> void:
	var remote_id := multiplayer.get_remote_sender_id()
	
	var ids : Array[String] = server_card_memory.attempt_card_to_hand( \
		PlayerManager.getUUID_from_PeerID(remote_id), set_index)
	
	_add_to_hand_local_mem.rpc_id(remote_id, ids, set_index, pack_id)
	Signalbus.emit_multiplayer_signal.rpc_id(remote_id, "confirmed_add_to_hand", [ids, set_index])

@rpc("any_peer","call_local")
func _add_to_hand_local_mem(ids : Array[String], set_index : int, pack_id : int) -> void:
	assert(!local_pack_mem.is_empty())
	var card_id_dicts : Dictionary[String, CardInstanceData] = local_pack_mem[pack_id][set_index] as Dictionary[String, CardInstanceData]
	for id in ids:
		local_player_hand.append(card_id_dicts[id])
	
	print(local_player_hand)
	pass

func local_search_hand(carddatainstance_id : String) -> CardInstanceData:
	for card_instance in local_player_hand:
		if card_instance.get_id() == carddatainstance_id:
			return card_instance
	return null

#@rpc("any_peer","call_local")
#func _add_to_hand(card_instance_ids : Array[String], set_id : int) -> void:
	#Signalbus.emit_signal(,)
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
