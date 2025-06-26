extends Object
class_name CardAttributeGenerator

var special_set_prob = 99
var special_card_num = 100

var is_debug = false
static var num_cards_generated := -1

var rng : RandomNumberGenerator


func _init(is_debug := false, seed := -1) -> void:
	self.is_debug = is_debug
	
	rng = RandomNumberGenerator.new()
	if seed == -1:
		rng.randomize()
	else:
		rng.set_seed(seed)
	pass
	
# cardpacks is an Array[Array[Dictionary[String, int]]] and outputs an Array[Array[Array[int]]]
# Cardpacks->Cardsets->card_id+quantity
func generate_cardpackstream(cardpacks : Array) -> Array:
	var cardpacks_total : Array[Array] = []
	
	var is_special_pack := false
	
	for cardpack in cardpacks:
		cardpacks_total.append(generate_cardpack_stream(cardpack))
		
	return cardpacks_total

func generate_cardpack_stream(cardpack : Array[Dictionary], all_special := false) -> Array:
	var cardpack_out = Array()
	var is_special_set := false
	for card_set in cardpack:
		if !is_debug and randi_range(0, 100) >= 99:
			is_special_set = true
		cardpack_out.append(generate_cardset_stream(card_set as Dictionary[String, int], is_special_set))
		is_special_set = false
	return cardpack_out

func generate_cardset_stream(cardset : Dictionary[String, int], all_special : bool) -> Array:
	var cardset_out := Array()
	for card in cardset.keys():
		for count in range(cardset[card]):
			if !all_special:
				cardset_out.append(generate_attribute(card))
			else:
				cardset_out.append([generate_instance_id(card), 100] )
	return cardset_out

func generate_card_stream(cards : Array[String]) -> Array:
	var output := Array()
	for card in cards:
		output.append(generate_attribute(card))
	return output

func generate_attribute(cardid : String) -> Array:
	num_cards_generated += 1
	if is_debug:
		return [cardid + str(num_cards_generated), num_cards_generated]
	return [cardid + str(num_cards_generated), randi_range(0, 100)]


func generate_instance_id(carddata_id : String) -> String:
	num_cards_generated += 1
	return carddata_id + str(num_cards_generated)
