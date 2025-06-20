extends CardPack
class_name MenuPack

var menu_cards := ["singleplayer", "multiplayer", "settings", "exit"]

@onready
var card_manager = get_tree().root.get_node("MainMenu/CardManager")
@onready
var player_hand = get_tree().root.get_node("MainMenu/PlayerHand")
@onready
var mouse_tut = get_node("AnimatedSprite2D")

func _ready() -> void:
	get_node("AnimationPlayer").play("fall animation")
	mouse_tut.play("default")
	get_node("AnimatedSprite2D/MouseFade").play("float")


func open_pack() -> void:
	self.get_node("Area2D/CollisionShape2D").disabled = true
	for card_id in menu_cards:
		var new_card = CardLoader.create_card(card_id)
		new_card.position = position
		card_manager.add_child(new_card)
		player_hand.add_to_hand(new_card)
		new_card.get_node("Area2D/CollisionShape2D").disabled = false
	self.dissolving = true
	get_node("AnimatedSprite2D/MouseFade").play("fade")
