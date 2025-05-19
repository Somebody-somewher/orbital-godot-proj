# Handles Animations for Cards 
extends Node2D

var card_dragged : Card
var card_hovered : Card
var flip_zone : int = 0
var card_flipped : bool = false 
var tweening : Tween
var screen_size : Vector2

const CARD_COLLISION_MASK = 1

# TODO: Ideally we can remove this once we get the CardManager -> Board Working
const TILE_COLLISION_MASK = 2
const PACK_COLLISION_MASK = 8
const CARD_EASE = 0.13

@onready
var player_hand_ref = $"../PlayerHand"
@onready
var input_manager_ref = $"../InputManager"

@export
var board_ref : Board

func _ready() -> void:
	screen_size = get_viewport_rect().size
	board_ref = $"../Board"
	#InputManager.connect(clicked, )

func _process(delta: float) -> void:
	if card_dragged:
		if Input.is_action_just_released("leftMouseClick"):
			finish_drag()
		else:
			# dragged_card sticking to mouse
			var mouse_pos = get_global_mouse_position()
			var new_x = (mouse_pos.x - card_dragged.position.x) * CARD_EASE + card_dragged.position.x
			var new_y = (mouse_pos.y - card_dragged.position.y) * CARD_EASE + card_dragged.position.y
			card_dragged.position = Vector2(clamp(new_x, 0, screen_size.x), clamp(new_y, 0, screen_size.y))
			
			# card flipping when near tile
			if board_ref != null:
				if !card_flipped and board_ref.mouse_near_board():
					card_flipped = true
					card_dragged.card_flip_to_entity()
				if card_flipped and !board_ref.mouse_near_board():
					card_dragged.entity_flip_to_card()
					card_flipped = false

func start_drag(card):
	var tile_check = select_raycast(TILE_COLLISION_MASK)
	if tile_check:
		tile_check.tile_built = false
		card_flipped = true
	
	card_dragged = card
	player_hand_ref.remove_from_hand(card_dragged)
	
	if !card_hovered:
		highlight_card(card, true)
		card_hovered = card
	
	card_dragged.in_tile = false

#TODO: Need you to code the cards such that they can plop down the building onto the board
# Right now the board has the following functions which will help
# place_on_board_if_able(Placeable) -> bool returns  
func finish_drag():
	var tile_check = select_raycast(TILE_COLLISION_MASK)
		
	if card_hovered and !tile_check: ##plonks the card down
		highlight_card(card_hovered, false)
		card_hovered = null
	
	# check if dragged into a tile
	if tile_check and !tile_check.tile_built:
		card_dragged.in_tile = true
		tile_check.tile_built = true
		card_hovered = null
		card_dragged.rotation = 0
		card_dragged.scale = Vector2(1,1)
		card_dragged.position = tile_check.position
		##card_dragged.get_node("Area2D/CollisionShape2D").disabled = true
	else:
		if card_flipped:
			card_dragged.entity_flip_to_card()
		player_hand_ref.add_to_hand(card_dragged)
	
	card_flipped = false
	card_dragged = null

# TODO: This shouldn't be the CardManager's job?
# Can we throw this into the InputManager or CollisionManager
func select_raycast(mask) -> Card:
	var space_state : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state 
	
	# returns id of objects clicked on
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	params.collision_mask = mask
	var result : Array[Dictionary] = space_state.intersect_point(params)
	
	if !result.is_empty():
		return topmost_card(result)
		
	return null

# TODO: Can we throw this into the InputManager or CollisionManager
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

# Following functions are centralized under CardManager
# So as to prevent them all from being triggered at the same time

# Do the card hovering animation if there are no cards
# currently hovering or being dragged
func card_hover_on(card):
	if !card_dragged and !card_hovered:
		card_hovered = card
		highlight_card(card, true)

func card_hover_off(card):
	if card_hovered == card and card_dragged != card:
		highlight_card(card, false)
		var new_card_hovered = select_raycast(CARD_COLLISION_MASK)
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
		if !card.in_tile:
			card.rotation = card.deck_angle
		animate_card(card, Vector2(1, 1), Vector2(0, 0))
		card.z_index -= 10

# TODO: Can this be Card's job to handle?
func animate_card(card : Card, new_scale : Vector2, pos):
	if tweening and tweening.is_running():
		await tweening.finished
	tweening = get_tree().create_tween()
	if !card.in_tile:
		tweening.parallel().tween_property(card, "position", card.deck_pos + pos, 0.08)
	tweening.parallel().tween_property(card, "scale", new_scale, 0.08)
