extends Node2D

var card_arr = [["dummy", 1]] ##2d array of [card, number]
var card_set = [] ##set of actual objects
var destroyed = false

@onready
var card_manager = get_tree().root.get_node("GameManager/CardManager")
@onready
var player_hand = get_tree().root.get_node("GameManager/PlayerHand")
@onready
var input_manager = get_tree().root.get_node("GameManager/InputManager")

var database_ref = preload("res://scripts/Card/card_database.gd")
var card_scene = preload("res://scenes/Card/Card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for card_type in card_arr: ##card_type is of form [str, int]
		for i in range(card_type[1]):
			var new_card = card_scene.instantiate()
			var card_image_path = str("res://sprites/card_sprites/"+ card_type[0] + "_card.png")
			var tile_image_path = str("res://sprites/entity_sprites/"+ card_type[0] + ".png")
			new_card.get_node("CardImage").texture = load(card_image_path)
			new_card.get_node("EntityImage").texture = load(tile_image_path)
			new_card.get_node("Area2D/CollisionShape2D").disabled = true
			card_set.insert(card_set.size(), new_card)
			add_child(new_card)
	pass
	

func shift_to_hand():
	self.get_node("Area2D/CollisionShape2D").disabled = true
	destroyed = true
	for i in range(card_set.size()):
		var set_card = card_set[i]
		set_card.reparent(card_manager)
		player_hand.add_to_hand_no_update(set_card)
		player_hand.update_hand_pos()
		set_card.get_node("Area2D/CollisionShape2D").disabled = false

func _on_area_2d_mouse_entered() -> void:
	highlight_set(true)
	
func _on_area_2d_mouse_exited() -> void:
	if !destroyed:
		highlight_set(false)

func highlight_set(on):
	for i in range(card_set.size()):
		if on:
			var fan_angle = clamp(card_set.size() * 0.2, 0, PI/2)
			var new_tilt = 0 if card_set.size() == 1 else (i - (float(card_set.size()) - 1)/2) * fan_angle / (card_set.size() - 1)
			var x = 100 * sin(new_tilt);
			var y = -60 * cos(new_tilt) + 30;
			animate_card(card_set[i], new_tilt, 1.1, Vector2(x, y))
		else:
			animate_card(card_set[i], 0, 1, Vector2(0,0))
		

func animate_card(card, new_angle, new_scale, pos):
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(card, "position", pos, 0.05)
	tween.parallel().tween_property(card, "rotation", new_angle, 0.1)
	tween.parallel().tween_property(card, "scale", Vector2(new_scale, new_scale), 0.1)
