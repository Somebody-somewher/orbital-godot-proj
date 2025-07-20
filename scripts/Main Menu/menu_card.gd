extends PlaceableCard
class_name MenuCard

#for constructor
static var menu_card_script := preload("res://scripts/Main Menu/menu_card.gd")

static func new_menucard(card_data : CardData, cardimg_bg : Texture2D) -> PlaceableCard:
	var card := card_scene.instantiate()
	card.set_script(menu_card_script)
	card.menucard_set_up(card_data, cardimg_bg)
	return card

func menucard_set_up(card_data : CardData, cardimg_bg : Texture2D) -> void:
	get_node("CardImage").texture = cardimg_bg
	get_node("EntityImage").texture = card_data.card_sprite
	get_node("Texts/CardName").text = card_data.display_name
	self.cardinstance_dataid = card_data.get_id()
