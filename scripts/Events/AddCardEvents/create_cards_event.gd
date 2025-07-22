extends CardEvent
class_name CreateCardEvent

# cards to create in card id, no of cards pairs
@export var cards: Dictionary[String, int]
@export var probability : Dictionary[String, int]

# destroys the building, #TODO building should trigger its own OnDestroyEvents
func trigger(card_mem : ServerCardMemory, caller : CardInstanceData) -> void:
	for key in cards.keys():
		for no in range(cards[key]):
			if !probability.has(key) or randi_range(0,100) >= probability[key]: 
				var instance = CardLoader.create_data_instance(key, -1)
				instance.set_owner_uuid(caller.get_owner_uuid())
				card_mem.add_card_in_hand(instance, caller.get_owner_uuid())

			#Signalbus.emit_signal("spawn_card", key, Vector2i(0,0))
			#board.get_global_tile_pos(tile_pos)
