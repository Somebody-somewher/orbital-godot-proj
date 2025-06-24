extends GutTest

var cardset_grp := preload("res://Resources/ResourceGrps/CardSetGrp.tres")
var csa : CardSetAllocator
var cardattr : CardAttributeGenerator

func before_each() -> void:
	csa = CardSetAllocator.new(cardset_grp, false)
	cardattr = CardAttributeGenerator.new(true)

func after_each() -> void:
	pass

func test_loading_cardsets() -> void:
	var sets := csa.get_all_sets_as_dicts()
	var set_names := csa.cardset_options
	for cardset_index in range(len(sets)):
		assert_eq(sets[cardset_index].is_empty(), false, "Cardset " + set_names[cardset_index].get_id() + " is Null or has error loading!")
	
	var sets_nums := cardattr.generate_cardpack_stream(sets)
	
	var cardset_arr : Array = CardLoader.get_cards_for_pack(sets, sets_nums)
	
	var cardindex := 0
	var cardset_dict : Dictionary[String, int]
	
	var datainsts : Array = CardLoader.local_cardpacks_datainst_mem[0]
	
	# Check that a CardInstanceData was created for each  
	for cardset_index in range(len(sets)): 
		cardset_dict = sets[cardset_index] as Dictionary[String, int]
		for card_id in cardset_dict.keys():
			for count in cardset_dict[card_id]:
				assert_eq(card_id, datainsts[cardset_index].values()[cardindex + count].data.get_id(), "Misaligned or missing Cardinstancedata")
			cardindex += cardset_dict[card_id]
		cardindex = 0

	var card : Card
	for cardset_index in range(len(datainsts)):
		for card_index in range(len(datainsts[cardset_index])):
			card = cardset_arr[cardset_index][card_index]
			assert_eq(datainsts[cardset_index].keys()[card_index], card.get_data_instance_id(), "Card was not created for datainstance?")
			card.queue_free()

	#CardLoader.get_cards_for_set()
