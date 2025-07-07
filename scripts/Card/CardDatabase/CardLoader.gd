extends Node

@export var card_scene : PackedScene
@export var building_card_scene : PackedScene
var card_dict = {}


@export_category("BuildingCard Creation")
# BuildingData
@export var buildingcard_img : Texture2D
@export var building_grp : ResourceGroup
var buildings : Array[BuildingData] = []

@export_category("AuraCard Creation")
@export var aura_grp : ResourceGroup
var auras : Array[AuraCardData] = []

## Server
var card_attribute_gen : CardAttributeGenerator
var card_mem : CardMemory
@onready var cardpack_gen : CardPackGenerator = $CardPackGen

#for constructors
#var building_card_scene: PackedScene = preload("res://scenes/Card/building_card.tscn")
var aura_card_scene: PackedScene = preload("res://scenes/Card/aura_card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load all buildings data 
	building_grp.load_all_into(buildings)
	
	for b in buildings:
		if b:
			card_dict.get_or_add(b.get_id(), b)

	for aura_data in auras:
		if aura_data:
			card_dict.get_or_add(aura_data.id_name, aura_data)

	if multiplayer.is_server():
		card_mem = ServerCardMemory.new()
	else:
		card_mem = CardMemory.new()
	add_child(card_mem)
	#NetworkManager.mark_client_ready(self.name)

## This is here because some things need to wait for NetworkManager or PlayerManager to setup before firing
## Run via GameManager in actual game
func setup(cag : CardAttributeGenerator = null, csa : CardSetAllocator = null) -> void:
	if multiplayer.is_server():	
		
		if cag == null:
			card_attribute_gen = CardAttributeGenerator.new()
		else:
			card_attribute_gen = cag

		cardpack_gen.server_setup(card_attribute_gen, csa)
	
	card_mem.setup()
	cardpack_gen.setup(card_mem, create_data_instance, create_card)


################################## CARD CREATION LOGIC #######################################

# Called by client and server. However, be wary when randomizing attribute num when using this. 
# NOTE: WHEN RANDOMIZING: The Server must call this function, generate the attribute num and instance_id
# Then call function with the generated attribute num and instance_id derived from the server's CardInstanceData
@rpc("any_peer", "call_local")
func create_data_instance(data_id : String, attribute_number : int = 0, instance_id : String = "") -> CardInstanceData:
	
	# NOTE: IF THE CLIENT IS CALLING THIS FUNCTION, ATTRIBUTE NUMBER CANNOT BE -1
	# EITHER PUT IT AS 0 OR THE ATTRIBUTE NUMBER THAT CREATED THE CARD
	
	# int and string instance_id pair
	if instance_id == "":
		if attribute_number == -1:
			assert(multiplayer.is_server())
			var gen_values = card_attribute_gen.generate_attribute(data_id)
			
			attribute_number = gen_values[0]
			instance_id = gen_values[1]
		else:
			instance_id = card_attribute_gen.generate_instance_id(data_id)
	
	var data : CardData = card_dict[data_id]
	var instance_data : CardInstanceData 
	
	if data is BuildingData:
		instance_data =  BuildingInstanceData.new(instance_id, data as BuildingData, attribute_number)
	else:
		instance_data = null
	
	# THIS CODE TRIGGERS IN SERVER WHEN PACK IS CHOSEN AND CONFIRMED
	# if NetworkManager.isclient():
	#	modify(instance_data) for e.g. if there is an aura that makes 	
	
	return instance_data

#func duplicate_cardinstance(data : CardInstanceData) -> CardInstanceData:
	#
	#var gen_values = card_attribute_gen.fixed_generate_attribute(data.get_id(), data.)
	#
	#if data is BuildingInstanceData:
		#pass
		#
		#
		##return BuildingInstanceData.duplicate(data)
	#return null


# Add to scene must be done by manually by node calling this method
func create_card(data : CardInstanceData) -> Card:
	var card : Card
	if data is BuildingInstanceData:
		card = building_card_scene.instantiate()
		card.set_up(data, buildingcard_img)
		return card
	printerr("AURA?")
	return null

func client_modify(player_uuid : String, data : CardInstanceData) -> void:
	# AuraManager 
	pass
	

################################### ADDING TO HAND #################################################

#@rpc("any_peer","call_local")
#func attempt_add_to_hand(set_id : int, pack_id : int) -> void:
	#var remote_id := multiplayer.get_remote_sender_id()
	#
	#var ids : Array[String] = server_card_memory.attempt_card_to_hand( \
		#PlayerManager.getUUID_from_PeerID(remote_id), pack_id, set_id)
	#
	#_add_to_hand_local_mem.rpc_id(remote_id, ids, set_id, pack_id)
	#Signalbus.emit_multiplayer_signal.rpc_id(remote_id, "confirmed_add_to_hand", [ids, set_id])
#
#@rpc("any_peer","call_local")
#func _add_to_hand_local_mem(ids : Array[String], set_id : int, pack_id : int) -> void:
	#assert(!local_pack_mem.is_empty())
	#var card_id_dicts : Dictionary[String, CardInstanceData] = local_pack_mem[pack_id][set_id] as Dictionary[String, CardInstanceData]
	#for id in ids:
		#local_player_hand.append(card_id_dicts[id])
	#
	#print(local_player_hand)
	#pass

#func local_search_hand(carddatainstance_id : String) -> CardInstanceData:
	#for card_instance in local_player_hand:
		#if card_instance.get_id() == carddatainstance_id:
			#return card_instance
	#return null

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
	return card_dict.get(id)

func get_card_data(id : String) -> CardData:
	return card_dict.get(id)

func get_display_name(id : String) -> String:
	return card_dict.get(id).display_name

func get_texture(id : String) -> Texture2D:
	return card_dict.get(id).card_sprite


#func get_random_set(n : int) -> Array[CardSetData]:
	#var size = cardset_types.size()
	#var arr : Array[CardSetData] = []
	#for i in range(n):
		#arr.append(cardset_types[randi() % size])
	#return arr
