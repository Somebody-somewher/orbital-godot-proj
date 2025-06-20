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
	var output : Array[Array] = []
	
	var is_special_pack := false
	
	for cardpack in cardpacks:
		cardpacks_out = Array()
		for card_set in cardpack:
			if randi_range(0, 100) >= 99:
				is_special_pack = true
			cardsets_out = Array()
			for card in card_set.keys():
				
				for count in range(card_set[card]):
					if !is_special_pack:
						cardsets_out.append(randi_range(0,100))
					else:
						cardsets_out.append(100)
			
			cardpacks_out.append(cardsets_out)
			is_special_pack = false
	
		output.append(cardpacks_out)
		
	return output
