extends Node2D

const card_scene = preload("res://scenes/Card/Card.tscn")
const SAMPLE_SIZE = 3

var centre_x
var screen_size

const MAX_HAND_RATIO = 0.6 ##ratio of hand width to screen
const MAX_HAND_TILT = 0.5
const HAND_Y_RATIO = 0.85

var hand_arr : Array[Card] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport().size
	centre_x = screen_size.x/2
	for i in range(SAMPLE_SIZE):
		add_to_hand(spawn_card())
		

func add_to_hand_no_update(card):
	card.initialize_building()
	hand_arr.insert(hand_arr.size(), card)

func add_to_hand(card):
	add_to_hand_no_update(card)
	update_hand_pos()

func remove_from_hand(card):
	if card in hand_arr:
		hand_arr.erase(card)
		update_hand_pos()

# sets card to nice positions
func update_hand_pos(): 
	var hand_size := hand_arr.size() as float
	var hand_ratio = clamp(hand_size * 0.07, 0, MAX_HAND_RATIO)
	var fan_angle = clamp(hand_size * 0.05, 0, MAX_HAND_TILT)
	for i in range(hand_size):
		var new_tilt = 0 if hand_size == 1 else (i - (hand_size - 1)/2) * fan_angle / (hand_size - 1)
		var new_x = centre_x if hand_size == 1 else (i - (hand_size - 1)/2) * screen_size.x * hand_ratio / (hand_size - 1) + centre_x
		var new_y= 0.00025*(new_x - centre_x)**2 + screen_size.y * HAND_Y_RATIO
		var card = hand_arr[i]
		card.deck_angle = new_tilt
		card.deck_pos = Vector2(new_x, new_y)
		card.rotation = new_tilt
		animate_card_to_pos(card, card.deck_pos)
	redraw_z()

func animate_card_to_pos(card, new_pos):
	card.scale = Vector2(1,1)
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(card, "position", new_pos, 0.2)

# resets the card z to fan nicely
func redraw_z():
	for i in range(hand_arr.size()):
		hand_arr[i].z_index = i

# testing function
func spawn_card():
	var new_card = card_scene.instantiate()
	new_card.position = Vector2(centre_x, get_viewport().size.y/2)
	$"../CardManager".add_child(new_card)
	return new_card
	
