extends Node2D
class_name CardSet

var cards_in_set : Array[Card]
var destroyed : bool = false
var set_id : int 
var card_pack : int

var card_manager
var player_hand
#@onready
#var input_manager = get_tree().root.get_node("GameManager/InputManager")

var card_scene = preload("res://scenes/Card/Card.tscn")

func set_up(card_set : Array, set_id : int) -> void:
	cards_in_set.assign(card_set)
	self.set_id = set_id
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(get_tree().root.get_node("GameManager/CardManager"))
	card_manager = get_tree().root.get_node("GameManager/CardManager")
	player_hand = get_tree().root.get_node("GameManager/PlayerHand")
	
	var z_count = 100
	for card_instance in cards_in_set: ##card_type is of form [CardInstance]
		card_instance.z_index = z_count
		card_instance.get_node("Area2D/CollisionShape2D").disabled = true
		add_child(card_instance)
		z_count += 2
			
	pass

# adds each card to player hand
func shift_to_hand() -> void:
	self.get_node("Area2D/CollisionShape2D").disabled = true
	destroyed = true
	for set_card in cards_in_set:
		set_card.reparent(card_manager)
		card_manager.connect_card_signals(set_card)
		player_hand.add_to_hand(set_card)
		set_card.get_node("Area2D/CollisionShape2D").disabled = false

func _on_area_2d_mouse_entered() -> void:
	highlight_set(true)
	
func _on_area_2d_mouse_exited() -> void:
	if !destroyed:
		highlight_set(false)

# fans out cards
func highlight_set(on : bool) -> void:
	for i in range(cards_in_set.size()):
		if on:
			var fan_angle = clamp(cards_in_set.size() * 0.2, 0, PI/2)
			var new_tilt = 0 if cards_in_set.size() == 1 else (i - (float(cards_in_set.size()) - 1)/2) * fan_angle / (cards_in_set.size() - 1)
			var x = 100 * sin(new_tilt);
			var y = -60 * cos(new_tilt) + 30;
			animate_card(cards_in_set[i], new_tilt, 1.1, Vector2(x, y))
		else:
			animate_card(cards_in_set[i], 0, 1, Vector2(0,0))

func animate_card(card : Card, new_angle : float, new_scale : float, pos : Vector2) -> void:
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(card, "position", pos, 0.05)
	tween.parallel().tween_property(card, "rotation", new_angle, 0.1)
	tween.parallel().tween_property(card, "scale", Vector2(new_scale, new_scale), 0.1)

func dissolve_set() -> void:
	for unchosen_card in cards_in_set:
		unchosen_card.dissolve_card()

func _shift_to_hand(num_to_shift : int) -> void:
	var set_card : Card 
	for index in range(num_to_shift):
		set_card = cards_in_set[index]
		set_card.reparent(card_manager)
		card_manager.connect_card_signals(set_card)
		player_hand.add_to_hand(set_card)
		set_card.get_node("Area2D/CollisionShape2D").disabled = false
