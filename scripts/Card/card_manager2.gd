# Handles Animations for Cards 
extends Node2D
class_name CardManager2

var card_dragged : Node2D
var card_hovered : Node2D
var card_flipped : bool = false 
var tweening : Tween
var screen_size : Vector2

const CARD_COLLISION_MASK = 1

const CARD_EASE := 0.13
# how big a card and scaled down to the tile size of the baord as Vector2
var CARD_TILE_RATIO : Vector2


@export var board_ref : BoardManager
@export var player_hand_ref : PlayerHand
@export var input_manager_ref : InputManager 

func _ready() -> void:
	screen_size = get_viewport_rect().size
	spawn_card("cow", Vector2i(0,0))
	#CARD_TILE_RATIO = Vector2.ONE * board_ref.TILE_SIZE / 120

func _process(_delta: float) -> void:
	if !card_dragged:
		return

	if Input.is_action_just_released("leftMouseClick"):
		finish_drag(true)
	else:
		# dragged_card sticking to mouse
		var mouse_pos = get_global_mouse_position()
		var new_x = (mouse_pos.x - card_dragged.position.x) * CARD_EASE + card_dragged.position.x
		var new_y = (mouse_pos.y - card_dragged.position.y) * CARD_EASE + card_dragged.position.y
		card_dragged.position = Vector2(new_x, new_y)
		#card_dragged.position = Vector2(clamp(new_x, 0, screen_size.x), clamp(new_y, 0, screen_size.y))

		# card effects with board interaction
		if board_ref != null and card_dragged is Card:
			card_flip_if_near_board()
			highlight_effects_when_hovering_card()

func start_drag(card : Node2D):
	card_dragged = card
	if card_dragged is Card:
		player_hand_ref.remove_from_hand(card_dragged)
	
		if !card_hovered:
			highlight_card(card, true)
			card_hovered = card

# placing is if trying to place in tile, false if just return card to hand no matter what
func finish_drag(placing : bool):
	if card_dragged and card_dragged is Card:
		var card_placed : bool
		if placing:
			card_placed = board_ref.place_on_board_if_able(card_dragged.building)
		else:
			card_placed = false
			
		if card_hovered and !card_placed: ##plonks the card down
			highlight_card(card_hovered, false)
			card_hovered = null

		# check if dragged into a tile
		if card_placed:
			card_hovered = null
			card_dragged.swap_to_effect(CARD_TILE_RATIO)
		else:
			if card_flipped:
				card_dragged.entity_flip_to_card()
			player_hand_ref.add_to_hand(card_dragged)
		
		board_ref.reset_preview()
		card_flipped = false
	card_dragged = null

func card_under_mouse() -> Card:
	var space_state : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state 
	
	# returns id of objects clicked on
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	params.collision_mask = CARD_COLLISION_MASK
	var result : Array[Dictionary] = space_state.intersect_point(params)
	
	if !result.is_empty():
		return topmost_card(result)
		
	return null

func topmost_card(card_arr) -> Card:
	var top_card : Card = card_arr[0].collider.get_parent()
	var max_z : int = top_card.z_index
	
	# Finds the card that has the z-value, 
	# return that as the top-card
	for i in range (1, card_arr.size()):
		var current : Card = card_arr[i].collider.get_parent()
		if current.z_index > max_z:
			top_card = current
			max_z = current.z_index
	return top_card

# highlighting signals for cards
func connect_card_signals(card : Card):
	card.connect("mouse_on", card_hover_on)
	card.connect("mouse_off", card_hover_off)

# Following functions for dragged Card interations with board
# they are only called when board_ref != null and card is being dragged

func card_flip_if_near_board() -> void:
	if !card_flipped and board_ref.is_mouse_near_board():
		card_flipped = true
		card_dragged.card_flip_to_entity()
	if card_flipped and !board_ref.is_mouse_near_board():
		card_dragged.entity_flip_to_card()
		card_flipped = false

func highlight_effects_when_hovering_card() -> void :
	# card ghost snapping to grid
	#board_ref.preview_placement()
	#var tile_pos_i = board_ref.get_mouse_tile_pos()
	#var tile_global_pos = board_ref.get_global_tile_pos(tile_pos_i)
	#if tile_global_pos != Vector2(Board.NULL_TILE):
		#card_dragged.get_node("GhostImage").visible = true
		#card_dragged.get_node("GhostImage").global_position = tile_global_pos
		#card_dragged.get_node("GhostImage").scale = CARD_TILE_RATIO
		#board_ref.preview_placement(card_dragged.building, tile_pos_i)
	#else:
		#card_dragged.get_node("GhostImage").visible = false
		#board_ref.reset_preview()
	pass

# Following functions are centralized under CardManager
# So as to prevent them all from being triggered at the same time
# position as global position to spawn card
func spawn_card(id_name : String, pos : Vector2) -> void:
	var new_card = BuildingCard.new_card(id_name)
	new_card.global_position = pos
	self.add_child(new_card)
	connect_card_signals(new_card)
	#new_card.connect_to_card_manager(self)
	player_hand_ref.add_to_hand(new_card)

# Do the card hovering animation if there are no cards
# currently hovering or being dragged
func card_hover_on(card):
	if !card_dragged and !card_hovered:
		card_hovered = card
		highlight_card(card, true)

func card_hover_off(card):
	if card_hovered == card and card_dragged != card:
		highlight_card(card, false)
		var new_card_hovered = card_under_mouse()
		card_hovered = null
		if new_card_hovered:
			card_hover_on(new_card_hovered)

# highlight or unhighlight card depending on second argument
func highlight_card(card : Card, hovering : bool):
	if hovering:
		card.rotation = 0
		animate_card(card, Vector2(1.15, 1.15), Vector2(0, -80))
		card.get_parent().move_child(card, -1)
		card.z_index += 10
	else:
		card.rotation = card.deck_angle
		animate_card(card, Vector2(1, 1), Vector2(0, 0))
		card.z_index -= 10

# TODO: Can this be Card's job to handle?
func animate_card(card : Card, new_scale : Vector2, pos):
	if tweening and tweening.is_running():
		await tweening.finished
	tweening = get_tree().create_tween()
	tweening.parallel().tween_property(card, "position", card.deck_pos + pos, 0.08)
	tweening.parallel().tween_property(card, "scale", new_scale, 0.08)
