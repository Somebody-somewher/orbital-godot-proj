# Handles Animations for Cards 
extends Node2D
class_name CardManager

# for highlighting and animations
var card_dragged : Node2D
var card_hovered : Node2D
var card_flipped : bool = false 
var tweening : Tween
var screen_size : Vector2
var hover_enabled : bool = true

# Placing on board Logic
var has_received_response_signal := false
var is_request_successful : bool

const CARD_COLLISION_MASK = 1

const CARD_EASE := 0.13
# how big a card and scaled down to the tile size of the baord as Vector2
var CARD_TILE_RATIO : Vector2


@export var board_ref : BoardManagerClient
@export var player_hand_ref : PlayerHand
@export var input_manager_ref : InputManager 
@export var preview_board_ref : BoardPreviewerTileMap
var aura_cards = AuraGroup.new()

func _ready() -> void:
	Signalbus.connect("mouse_enter_interactable_board_tile", highlight_effects_when_hovering_card)
	Signalbus.connect("open_compendium", opening_ui)
	Signalbus.connect("register_to_cardmanager", register_to_cardmanager)
	
	Signalbus.connect("board_action_success", _on_boardrequest_success)
	Signalbus.connect("board_action_fail", _on_boardrequest_failure)

	screen_size = get_viewport_rect().size
	

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

		if card_dragged is AuraCard:
			return
		
		# card effects with board interaction
		if board_ref and card_dragged is Card:
			card_flip_if_near_board()

func register_to_cardmanager(card : Card):
	card.reparent(self)
	connect_card_signals(card)

func start_drag(card : Node2D):
	card_dragged = card
	if card_dragged is PlaceableCard:
		player_hand_ref.remove_from_hand(card_dragged)
		if !card_hovered:
			highlight_card(card, true)
			card_hovered = card

# placing is if trying to place in tile, false if just return card to hand no matter what
func finish_drag(placing : bool):
	if card_dragged and card_dragged is Card:
		if card_dragged is AuraCard:
			placing = false
		
		var card_placed : bool
		if placing:
			board_ref.place_cardplaceable(card_dragged.get_data_instance_id())
			card_placed = await await_boardrequest_result()
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
			if card_dragged is PlaceableCard:
				player_hand_ref.add_to_hand(card_dragged)
		
		preview_board_ref.reset_preview()
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
	if !card_flipped and board_ref.is_mouse_near_interactable_board():
		card_flipped = true
		card_dragged.card_flip_to_entity()
	if card_flipped and !board_ref.is_mouse_near_interactable_board():
		card_dragged.entity_flip_to_card()
		card_flipped = false

func highlight_effects_when_hovering_card() -> void :
	# card ghost snapping to grid
	if card_dragged != null and card_dragged is PlaceableCard:
		preview_board_ref.reset_preview()
		preview_board_ref.preview_placement(card_dragged.get_data_instance_id())

	else:
		preview_board_ref.reset_preview()


## position as global position to spawn card
#func spawn_card(id_name : String, pos : Vector2) -> void:
	#var new_card = CardLoader.create_card(id_name)
	#new_card.global_position = pos
	#self.add_child(new_card)
	#new_card.connect_to_card_manager(self)
	#player_hand_ref.add_to_hand(new_card)


func opening_ui(_id : String) -> void :
	finish_drag(false)

#
## Following functions are centralized under CardManager
## So as to prevent them all from being triggered at the same time
#
## Do the card hovering animation if there are no cards
## currently hovering or being dragged
func card_hover_on(card):
	if !card_dragged and !card_hovered and hover_enabled:
		card_hovered = card
		highlight_card(card, true)

func card_hover_off(card):
	if card_hovered == card and card_dragged != card:
		highlight_card(card, false)
		card_hover_if_able()

func card_hover_if_able():
	var new_card_hovered = card_under_mouse()
	card_hovered = null
	if new_card_hovered:
		card_hover_on(new_card_hovered)
#
## highlight or unhighlight card depending on second argument
func highlight_card(card : Card, hovering : bool):
	if hovering:
		card.z_index += 10
	else:
		card.z_index -= 10
#
## TODO: Can this be Card's job to handle?
func animate_card(card : Card, new_scale : Vector2, pos):
	if tweening and tweening.is_running():
		await tweening.finished
	tweening = get_tree().create_tween()
	tweening.parallel().tween_property(card, "position", card.deck_pos + pos, 0.08)
	tweening.parallel().tween_property(card, "scale", new_scale * card.deck_scale, 0.08)


###################### MISC ##########################
func _on_boardrequest_success() -> void:
	if has_received_response_signal:
		return
	has_received_response_signal = true
	is_request_successful = true

func _on_boardrequest_failure() -> void:
	if has_received_response_signal:
		return
	has_received_response_signal = true
	is_request_successful = false
	
func await_boardrequest_result() -> bool:
	
	while !has_received_response_signal:
		await get_tree().process_frame
	
	has_received_response_signal = false
	return is_request_successful
