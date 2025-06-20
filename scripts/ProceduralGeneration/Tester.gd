extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var stupid : Array = [[{"test":2, "beep":1, "fool":4}, {"fake":2, "pool":1, "zool":2}], [{"test":2, "beep":1, "fool":4}, {"fake":1, "pool":1, "zool":1}]]
	#print(matrix)
	var z = CardAttributeGenerator.new()
	_get_cards_for_pack(stupid, z.generate_cardpackstream(stupid))


func _get_cards_for_pack(cardpacks : Array, attribute_numbers : Array) -> void:
	var output :  = []
	var cardpack_out : Array = []
	var cardset_out : Array = []
	
	for pack in range(len(cardpacks)):
		cardpack_out = Array()
		for cset in range(len(cardpacks[pack])):
			cardset_out = Array()
			for card in range(len(cardpacks[pack][cset].keys())):
				for count in range(cardpacks[pack][cset][cardpacks[pack][cset].keys()[card]]):
					cardset_out.append(cardpacks[pack][cset].keys()[card] + " " + str(attribute_numbers[pack][cset][count]))
			cardpack_out.append(cardset_out)
		output.append(cardpack_out)
	print(output)
