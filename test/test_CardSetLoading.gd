extends GutTest

var cardset_grp := preload("res://Resources/ResourceGrps/CardSetGrp.tres")
var csa : CardSetAllocator
var cardattr : CardAttributeGenerator
var cpg : CardPackGenerator

func before_each() -> void:
	csa = CardSetAllocator.new(cardset_grp, false)
	cardattr = CardAttributeGenerator.new(true)
	
	cpg = CardPackGenerator.new()
	cpg.setup(CardLoader._create_data_instance, CardLoader._create_card)
	cpg.server_setup(cardattr, ServerCardMemory.new(), csa)
	add_child_autoqfree(cpg)
	await get_tree().process_frame
	
func test_loading_cardsets() -> void:
	
	# Test of CardSetData even loads successfully in the first place
	var sets := csa.get_all_sets_as_dicts()
	var set_names := csa.cardset_options
	for cardset_index in range(len(sets)):
		assert_eq(sets[cardset_index].is_empty(), false, "Testing if " + set_names[cardset_index].get_id() + " loaded in successfully")
	
	# Generate things required to create the cardset
	var sets_nums := cardattr.generate_cardpack_stream(sets)
	var cardset_arr : Array = cpg.get_cards_for_pack(sets, sets_nums)
	
	# Check that a CardInstanceData was created for each card in the cardset
	# This means that there was a valid CardData for each card in the cardset 
	var cardindex := 0
	var cardset_dict : Dictionary[String, int]
	var datainsts : Array = cpg.local_cardpacks_datainst_mem[0]

	for cardset_index in range(len(sets)): 
		cardset_dict = sets[cardset_index] as Dictionary[String, int]
		for card_id in cardset_dict.keys():
			for count in cardset_dict[card_id]:
				assert_eq(card_id, datainsts[cardset_index].values()[cardindex + count].data.get_id(), "Checking if Cardinstancedata created sucessfully")
			cardindex += cardset_dict[card_id]
		cardindex = 0

	# Check that each stored CardInstanceData aligns with a Card
	var card : Card
	for cardset_index in range(len(datainsts)):
		for card_index in range(len(datainsts[cardset_index])):
			card = cardset_arr[cardset_index][card_index]
			assert_eq(datainsts[cardset_index].keys()[card_index], card.get_data_instance_id(), "Was card created with datainstance?")
			card.queue_free()
	
	cardattr.free()
	csa.free()
	await get_tree().process_frame
