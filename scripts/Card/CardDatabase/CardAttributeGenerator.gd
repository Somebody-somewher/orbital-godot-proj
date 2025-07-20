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
func generate_cardpackstream(cardpacks : Dictionary[int, Dictionary]) -> Dictionary[int, Dictionary]:
	var cardpacks_total : Dictionary[int, Dictionary]
	
	var is_special_pack := false
	
	for pack_id in cardpacks.keys():
		cardpacks_total[pack_id] = generate_cardpack_stream(cardpacks[pack_id])
		
	return cardpacks_total

func generate_cardpack_stream(cardpack : Dictionary[String, Dictionary], all_special := false) -> Dictionary[String, Array]:
	var cardpack_out : Dictionary[String, Array]
	var is_special_set := false
	
	for cardset_id in cardpack.keys():
		if !is_debug and randi_range(0, 100) >= 99:
			is_special_set = true
		cardpack_out[cardset_id] = generate_cardset_stream(cardpack[cardset_id], is_special_set)
		is_special_set = false
	return cardpack_out

func generate_cardset_stream(cardset : Dictionary[String, int], all_special : bool) -> Array[Array]:
	var cardset_out : Array[Array]
	for card in cardset.keys():
		for count in range(cardset[card]):
			if !all_special:
				cardset_out.append(generate_attribute(card))
			else:
				cardset_out.append([generate_instance_id(card), 100])
	return cardset_out

func generate_card_stream(cards : Array[String]) -> Array:
	var output : Array[Array]
	for card in cards:
		output.append(generate_attribute(card))
	return output

# NOTE: the first cards ids dont start at 0 cuz of procgen
func generate_attribute(cardid : String) -> Array:
	num_cards_generated += 1
	if is_debug:
		return [cardid + str(num_cards_generated), num_cards_generated]
	return [cardid + str(num_cards_generated), randi_range(0, 100)]

func generate_instance_id(carddata_id : String) -> String:
	num_cards_generated += 1
	return carddata_id + str(num_cards_generated)
