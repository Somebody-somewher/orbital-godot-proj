extends CardEvent
class_name GoodieCardEvent


@export var cards: Array = [
	"apple","bees","campfire","cottage","dirt","fence",
	"fountain","garden","hobo_tent","knight","lighthouse","mill",
	"mushroom","obelisk","rat","rat_swarm","sand","shovel",
	"silo","wheat_field","telescope","tomato","tombstone","trash",
	"wall","cactus","flowers","island","oasis","cow"]

func trigger(card_mem : ServerCardMemory, caller : CardInstanceData, pos := Vector2.ZERO) -> void:
	for i in range(randi_range(3,6)):
		var instance = CardLoader.create_data_instance(cards.pick_random(), -1)
		instance.set_owner_uuid(caller.get_owner_uuid())
		pos = Vector2((pos.x + 0.5) * 113, (pos.y + 0.5) * 113)
		card_mem.add_card_in_hand(instance, caller.get_owner_uuid(), pos)
