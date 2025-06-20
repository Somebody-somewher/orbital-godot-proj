extends Object
class_name CardAttributeGenerator

var special_set_prob = 99
var special_card_num = 100

func _init() -> void:
	pass
	
# cardpacks is an Array[Array[Dictionary[String, int]]] and outputs an Array[Array[Array[int]]]
# Cardpacks->Cardsets->card_id+quantity
func generate_cardpackstream(cardpacks : Array) -> Array:
	var cardpacks_out : Array = []
	var cardsets_out : Array = []
	var cards_out : Array
	
	var is_special_pack := false
	
	for cardpack in cardpacks:
		cardsets_out = Array()
		for card_set in cardpack:
			if randi_range(0, 100) >= 99:
				is_special_pack = true
			cards_out = Array()
			for card in card_set.keys():
				
				for count in range(card_set[card]):
					if !is_special_pack:
						cards_out.append(randi_range(0,100))
					else:
						cards_out.append(100)
			
			cardsets_out.append(cards_out)
			is_special_pack = false
	
		cardpacks_out.append(cardsets_out)
		
	return cardpacks_out
