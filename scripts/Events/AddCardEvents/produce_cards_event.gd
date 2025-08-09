extends BoardEvent
class_name ProduceCardsEvent

##ONLY FOR TUTORIAL USE

@export var cards: Dictionary[String, int]
@export var probability : Dictionary[String, int]

func trigger(board : BoardMatrixData, tile_pos : Vector2i, caller : CardInstanceData) -> void:
	for key in cards.keys():
		for no in range(cards[key]):
			if !probability.has(key) or randi_range(0,100) <= probability[key]: 
				var instance = CardLoader.create_data_instance(key, -1)
				instance.set_owner_uuid(caller.get_owner_uuid())
				var pos = Vector2(800, 450)
				(CardLoader.card_mem as ServerCardMemory).add_card_in_hand(instance, caller.get_owner_uuid(), pos)
