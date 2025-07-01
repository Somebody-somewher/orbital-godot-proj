extends Node
class_name AuraGroup

var aura_arr : Array[AuraCard] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func add(card : AuraCard) -> void:
	aura_arr.append(card)

func add_many(cards : Array[AuraCard]) -> void:
	aura_arr.append_array(cards)

func remove(card : AuraCard) -> void:
	if card in aura_arr:
		aura_arr.erase(card)

func process_events(event_arr : Array[BoardEvent]) -> Array[BoardEvent]:
	var ret_arr = event_arr
	for aura_card in aura_arr:
		ret_arr = aura_card.modify_events(ret_arr)
	return ret_arr
