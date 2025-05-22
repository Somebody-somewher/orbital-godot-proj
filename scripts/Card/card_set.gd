extends Node2D
class_name CardSet

var card_arr = [["dummy", 1]] ##2d array of [card, number]
var card_set : Array[Card] = [] ##set of actual objects
var destroyed : bool = false

@onready
var card_manager = get_tree().root.get_node("GameManager/CardManager")
@onready
var player_hand = get_tree().root.get_node("GameManager/PlayerHand")
#@onready
#var input_manager = get_tree().root.get_node("GameManager/InputManager")

var card_scene = preload("res://scenes/Card/Card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for card_type in card_arr: ##card_type is of form [str, int]
		for i in range(card_type[1]):
			var new_card = Card.new_card(card_type[0])
			new_card.get_node("Area2D/CollisionShape2D").disabled = true
			card_set.insert(card_set.size(), new_card)
			add_child(new_card)
	pass

# adds each card to player hand
func shift_to_hand() -> void:
	self.get_node("Area2D/CollisionShape2D").disabled = true
	destroyed = true
	for set_card in card_set:
		set_card.reparent(card_manager)
		player_hand.add_to_hand(set_card)
		set_card.get_node("Area2D/CollisionShape2D").disabled = false

func _on_area_2d_mouse_entered() -> void:
	highlight_set(true)
	
func _on_area_2d_mouse_exited() -> void:
	if !destroyed:
		highlight_set(false)

# fans out cards
func highlight_set(on : bool) -> void:
	for i in range(card_set.size()):
		if on:
			var fan_angle = clamp(card_set.size() * 0.2, 0, PI/2)
			var new_tilt = 0 if card_set.size() == 1 else (i - (float(card_set.size()) - 1)/2) * fan_angle / (card_set.size() - 1)
			var x = 100 * sin(new_tilt);
			var y = -60 * cos(new_tilt) + 30;
			animate_card(card_set[i], new_tilt, 1.1, Vector2(x, y))
		else:
			animate_card(card_set[i], 0, 1, Vector2(0,0))


func animate_card(card : Card, new_angle : float, new_scale : float, pos : Vector2) -> void:
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(card, "position", pos, 0.05)
	tween.parallel().tween_property(card, "rotation", new_angle, 0.1)
	tween.parallel().tween_property(card, "scale", Vector2(new_scale, new_scale), 0.1)
