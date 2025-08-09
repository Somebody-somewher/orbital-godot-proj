extends Node2D
class_name PlayerHand

var centre_x
var og_screen_size : Vector2

var pos_offset := Vector2.ZERO
var zoom_var := 1.0

const MAX_HAND_RATIO = 0.6 ##ratio of hand width to screen
const MAX_HAND_TILT = 0.5
const HAND_Y_RATIO = 0.85

var hand_arr : Array[Card] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	og_screen_size = Vector2(1600,900)#get_viewport().size
	
	Signalbus.connect("add_to_hand", add_card_to_hand)

#func add_cards_to_hand(cards : Array[Card]) -> void:
	#for card in cards:
		#add_card_to_hand(card)

func add_to_hand_no_update(card) -> void:
	if card is AuraCard:
		return
	AudioManager.play_sfx("swipe")
	card.deck_scale = 1 / zoom_var
	card.initialize_card_effect()
	hand_arr.insert(hand_arr.size(), card)

func add_card_to_hand(card) -> void:
	card.get_node("Area2D/CollisionShape2D").disabled = false
	add_to_hand_no_update(card)
	update_hand_pos()

func remove_from_hand(card) -> void:
	if card in hand_arr:
		hand_arr.erase(card)
		update_hand_pos()

func discard_hand() -> void:
	for card in hand_arr:
		card.dissolving = true
	hand_arr = []
	update_hand_pos()

# sets card to nice positions
func update_hand_pos() -> void:
	var hand_size := hand_arr.size() as float
	var hand_ratio = clamp(hand_size * 0.07, 0, MAX_HAND_RATIO)
	var fan_angle = clamp(hand_size * 0.05, 0, MAX_HAND_TILT)
	var screen_size = og_screen_size/zoom_var
	
	centre_x = screen_size.x/2 + pos_offset.x
	
	for i in range(hand_size):
		var new_tilt = 0 if hand_size == 1 else (i - (hand_size - 1)/2) * fan_angle / (hand_size - 1)
		var new_x = centre_x if hand_size == 1 else (i - (hand_size - 1)/2) * screen_size.x * hand_ratio / (hand_size - 1) + centre_x
		var new_y= 0.00025* zoom_var*(new_x - centre_x)**2 + screen_size.y * HAND_Y_RATIO + pos_offset.y
		var card = hand_arr[i]
		card.deck_angle = new_tilt
		card.deck_pos = Vector2(new_x, new_y)
		card.rotation = new_tilt
		card.scale = Vector2.ONE * card.deck_scale
		animate_card_to_pos(card, card.deck_pos)
	redraw_z()

# only used for camera panning and zoom
func snap_to_hand_pos() -> void:
	var hand_size := hand_arr.size() as float
	var hand_ratio = clamp(hand_size * 0.07, 0, MAX_HAND_RATIO)
	var screen_size = og_screen_size/zoom_var
	
	centre_x = screen_size.x/2 + pos_offset.x
	for i in range(hand_size):
		var new_x = centre_x if hand_size == 1 else (i - (hand_size - 1)/2) * screen_size.x * hand_ratio / (hand_size - 1) + centre_x
		var new_y= 0.00025* zoom_var *(new_x - centre_x)**2 + screen_size.y * HAND_Y_RATIO + pos_offset.y
		var card = hand_arr[i]
		card.deck_pos = Vector2(new_x, new_y)
		card.deck_scale = 1 / zoom_var
		card.scale = Vector2.ONE * card.deck_scale
		card.position = card.deck_pos

func animate_card_to_pos(card, new_pos) -> void:
	card.scale = Vector2.ONE * card.deck_scale
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(card, "position", new_pos, 0.2)

# resets the card z to fan nicely
func redraw_z() -> void:
	for i in range(hand_arr.size()):
		hand_arr[i].z_index = 1000 + i*2

func clamp_pos_to_screen(new_x, new_y):
	var screen_size = og_screen_size/zoom_var
	return Vector2(clamp(new_x - pos_offset.x, 0, screen_size.x), clamp(new_y - pos_offset.y, 0, screen_size.y)) + pos_offset
