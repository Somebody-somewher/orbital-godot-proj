extends GutTest

var cardset_grp := preload("res://Resources/ResourceGrps/CardSetGrp.tres")
var csa : CardSetAllocator
var cag : CardAttributeGenerator

var housing_set := preload("res://Resources/CardSetData/Housing.tres")
var farm_set := preload("res://Resources/CardSetData/Farm.tres")
var alcohol := preload("res://Resources/CardSetData/Alcohol.tres")
var rats := preload("res://Resources/CardSetData/RATS.tres")

var cpm : CardPackManagerClient

var numsets_to_generate := 2

func before_each() -> void:
	
	if multiplayer.is_server():
		csa = CardSetAllocator.new(cardset_grp, false, 1)
		csa.debug_setup([housing_set.get_id(), farm_set.get_id(), alcohol.get_id(), rats.get_id()], numsets_to_generate)
	else:
		csa = null
	
	cag = CardAttributeGenerator.new(false, 1)
	
	cpm = CardPackManagerClient.new()
	cpm.spawn_node = cpm
	add_child_autoqfree(cpm)
	
	CardLoader.setup(cag, csa)
	pass

func packgen_test() -> Array[Array]:
	var output : Array[Array]
	for i in range(PlayerManager.getNumPlayers()):
		if i % 2 == 0:
			output.append([housing_set.cards, farm_set.cards])
		else:
			output.append([alcohol.cards, rats.cards])
	return output

func test_cardpack() -> void:
	# Assumes only one player
	# Checks if the pack generation is fixed (as it should be)
	var packs_data : Array[Array] = csa.get_packs()
	assert_eq(packs_data, packgen_test())
	csa.cardset_creation_count = 0
	
	if multiplayer.is_server():
		CardLoader.cardpack_gen.server_generate_packs()
		
	assert_eq(cpm.card_pack_nodes.size(), PlayerManager.getNumPlayers(), "Pack Generated")
	
	var cardinst_data_arr := CardLoader.cardpack_gen.local_cardpacks_datainst_mem
	var pack : CardPack
	var cardset : Array
	var card : Card
	
	
	var curr_set_data : Dictionary[String, int]
	var curr_set_data_gen : Dictionary[String, CardInstanceData]
	var start_count := 0
	
	for pack_index in range(len(cpm.card_pack_nodes)):
		pack = cpm.card_pack_nodes[pack_index] as CardPack
		assert_eq(pack.pack_id, pack_index)
		assert_eq(pack.pack_sets.size(), numsets_to_generate, "Sets Number correct")
		for cardset_index in range(len(pack.pack_sets)):
			cardset = pack.pack_sets[cardset_index]
			
			curr_set_data_gen = cardinst_data_arr[pack_index][cardset_index]
			for card_index in range(len(cardset)):
				card = cardset[card_index] as Card
				assert_eq(card.get_data_instance_id(), curr_set_data_gen.keys()[card_index])
			
			curr_set_data = packs_data[pack_index][cardset_index]
			for card_id in curr_set_data.keys():
				for count in curr_set_data[card_id]:
					assert_eq(curr_set_data_gen.values()[start_count + count].data.get_id(), card_id)
				start_count += curr_set_data[card_id]
			start_count = 0
	
	pack = cpm.card_pack_nodes[0]
	pack.open_pack()
	pack.select_option(pack.pack_arr[0])

func test_cardpack2() -> void:
	# Assumes only one player
	# Checks if the pack generation is fixed (as it should be)
	var packs_data : Array[Array] = csa.get_packs()
	assert_eq(packs_data, packgen_test())
	csa.cardset_creation_count = 0
	
	if multiplayer.is_server():
		CardLoader.cardpack_gen.server_generate_packs()
		
	assert_eq(cpm.card_pack_nodes.size(), PlayerManager.getNumPlayers(), "Pack Generated")
	
	var cardinst_data_arr := CardLoader.cardpack_gen.local_cardpacks_datainst_mem
	var pack : CardPack
	var cardset : Array
	var card : Card
	
	
	var curr_set_data : Dictionary[String, int]
	var curr_set_data_gen : Dictionary[String, CardInstanceData]
	var start_count := 0
	
	print(cardinst_data_arr)
	for pack_index in range(len(cpm.card_pack_nodes)):
		pack = cpm.card_pack_nodes[pack_index] as CardPack
		assert_eq(pack.pack_index, pack_index, "Pack indexing correct")
		assert_eq(pack.pack_sets.size(), numsets_to_generate, "Sets Number correct")
		for cardset_index in range(len(pack.pack_sets)):
			cardset = pack.pack_sets[cardset_index]
			
			curr_set_data_gen = cardinst_data_arr[pack_index][cardset_index]
			for card_index in range(len(cardset)):
				card = cardset[card_index] as Card
				assert_eq(card.get_data_instance_id(), curr_set_data_gen.keys()[card_index])
			
			curr_set_data = packs_data[pack_index][cardset_index]
			for card_id in curr_set_data.keys():
				for count in curr_set_data[card_id]:
					assert_eq(curr_set_data_gen.values()[start_count + count].data.get_id(), card_id)
				start_count += curr_set_data[card_id]
			start_count = 0
	
	

func after_each() -> void:
	var pack : CardPack
	var cardset : Array
	var card : Card
	
	for pack_index in range(len(cpm.card_pack_nodes)):
		pack = cpm.card_pack_nodes[pack_index] as CardPack
		assert_eq(pack.pack_index, pack_index)
		assert_eq(pack.pack_sets.size(), numsets_to_generate, "Sets Number correct")
		for cardset_index in range(len(pack.pack_sets)):
			cardset = pack.pack_sets[cardset_index]
			
			for card_index in range(len(cardset)):
				card = cardset[card_index] as Card
				card.queue_free()
				
	cag.free()
	csa.free()
	PlayerManager.addPlayer("TEST2", 2, "TEST2")
	await get_tree().process_frame
	#print(CardLoader.cardpack_gen.local_cardpacks_datainst_mem)
	
	
