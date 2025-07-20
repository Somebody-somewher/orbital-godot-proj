extends GutTest

var cardset_grp := preload("res://Resources/ResourceGrps/CardSetGrp.tres")
var csa : CardSetAllocator
var cardattr : CardAttributeGenerator
var cpg : CardPackGenerator
var card_memory : CardMemory

func before_each() -> void:
	csa = CardSetAllocator.new(cardset_grp, false)
	cardattr = CardAttributeGenerator.new(true)
	card_memory = ServerCardMemory.new()
	cpg = CardPackGenerator.new()
	cpg.setup(card_memory, CardLoader.create_data_instance, CardLoader.create_card)
	cpg.server_setup(cardattr, csa)
	add_child_autoqfree(cpg)
	await get_tree().process_frame
	
func test_loading_cardsets() -> void:
	
	# Test of CardSetData even loads successfully in the first place
	var sets : Dictionary[String, Dictionary] = csa.get_all_sets_as_dicts()
	for cardset_index in sets.keys():
		assert_eq(sets[cardset_index].is_empty(), false, "Testing if " + cardset_index + " loaded in successfully")
	
	# Generate things required to create the cardset
	var sets_nums := cardattr.generate_cardpack_stream(sets)
	var cardset_arr : Dictionary = cpg.get_cards_for_pack(sets, sets_nums)
	
	# Check that a CardInstanceData was created for each card in the cardset
	# This means that there was a valid CardData for each card in the cardset 
	var cardindex := 0
	var cardset_dict : Dictionary[String, int]
	var datainsts : Dictionary[String, Dictionary] = cpg._local_cardpack_datainst_mem

	for cardset_name in sets.keys(): 
		cardset_dict = sets[cardset_name] as Dictionary[String, int]
		for card_id in cardset_dict.keys():
			for count in cardset_dict[card_id]:
				assert_eq(card_id, datainsts[cardset_name].values()[cardindex + count].data.get_id(), "Checking if Cardinstancedata created sucessfully")
			cardindex += cardset_dict[card_id]
		cardindex = 0

	# Check that each stored CardInstanceData aligns with a Card
	var card : Card
	for cardset_name in datainsts:
		for card_index in range(len(datainsts[cardset_name])):
			card = cardset_arr[cardset_name][card_index]
			assert_eq(datainsts[cardset_name].keys()[card_index], card.get_data_instance_id(), "Was card created with datainstance?")
			card.queue_free()
	
	cardattr.free()
	csa.free()
	await get_tree().process_frame
