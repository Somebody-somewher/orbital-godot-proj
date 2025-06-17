extends Card
class_name AuraCard

var auras : Array[EventModifier]

# factory constructor
# TODO: pass the placeabale_data as the param instead?
static func new_card(card_name : String) -> Card:
	var data = CardLoader.get_building_data(card_name)
	var return_card : AuraCard = CardLoader.aura_card_scene.instantiate()
	var card_image_path = str("res://assets/card_sprites/blank_card.png")
	return_card.get_node("CardImage").texture = load(card_image_path)
	return_card.get_node("EntityImage").texture = data.card_sprite
	return_card.get_node("Texts/CardName").text = data.display_name
	return_card.id_name = card_name
	return return_card
	

# called when added to player hand
func initialize_card_effect() -> void:
	pass
	#for aura_data in data.

# called when added to board
# fully replace card with effect, then free self instance
func swap_to_effect(scale_by: Vector2) -> void:
	pass
