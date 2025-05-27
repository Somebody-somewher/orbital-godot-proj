extends CardPack
var menu_card := ["singleplayer", "multiplayer", "settings", "exit"]

@onready
var card_manager = get_tree().root.get_node("MainMenu/CardManager")
@onready
var player_hand = get_tree().root.get_node("MainMenu/PlayerHand")

func _ready() -> void:
	get_node("Sprite2D").texture = load("res://assets/card_packs/menu_pack.png")

func open_pack() -> void:
	self.get_node("Area2D/CollisionShape2D").disabled = true
	for card in menu_card:
		var new_card = MenuCard.new_card(card)
		new_card.position = position
		player_hand.add_to_hand(new_card)
		card_manager.add_child(new_card)
		new_card.connect_to_card_manager(card_manager)
	self.dissolving = true
