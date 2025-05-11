extends Node2D

var card_dragged
var card_hovered
var flip_zone = 0
var card_flipped = false
var tweening
var screen_size

const CARD_COLLISION_MASK = 1
const TILE_COLLISION_MASK = 2
const PACK_COLLISION_MASK = 8
const CARD_EASE = 0.13

@onready
var player_hand_ref = $"../PlayerHand"
@onready
var input_manager_ref = $"../InputManager"
@onready
var board_ref = $"../Board"

func _ready() -> void:
	screen_size = get_viewport_rect().size
	input_manager_ref.connect("left_mouse_released", left_mouse_released)

func _process(delta: float) -> void:
	if card_dragged:
		var mouse_pos = get_global_mouse_position()
		var new_x = (mouse_pos.x - card_dragged.position.x) * CARD_EASE + card_dragged.position.x
		var new_y = (mouse_pos.y - card_dragged.position.y) * CARD_EASE + card_dragged.position.y
		card_dragged.position = Vector2(clamp(new_x, 0, screen_size.x), clamp(new_y, 0, screen_size.y))
		if !card_flipped and board_ref.mouse_near_board(mouse_pos):
			card_flipped = true
			card_dragged.get_node("FlipAnimation").play("card_flip_to_entity")
		if card_flipped and !board_ref.mouse_near_board(mouse_pos):
			card_dragged.get_node("FlipAnimation").play("entity_flip_to_card")
			card_flipped = false

func left_mouse_released():
	if card_dragged:
		finish_drag()

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

func finish_drag():
	var tile_check = select_raycast(TILE_COLLISION_MASK)
	if card_hovered and !tile_check: ##plonks the card down
		highlight_card(card_hovered, false)
		card_hovered = null
			
	##check if dragged into a tile
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
			card_dragged.get_node("FlipAnimation").play("entity_flip_to_card")
		player_hand_ref.add_to_hand(card_dragged)
	
	card_flipped = false
	card_dragged = null

##returns id of objects clicked on (which card)
func select_raycast(mask):
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	params.collision_mask = mask
	var result = space_state.intersect_point(params)
	if result.size() > 0 :
		return topmost_card(result)
	return null

##from arr picks topmost card
func topmost_card(card_arr):
	var top_card = card_arr[0].collider.get_parent()
	var max_z = top_card.z_index
	
	for i in range (1, card_arr.size()):
		var current = card_arr[i].collider.get_parent()
		if current.z_index > max_z:
			top_card = current
			max_z = current.z_index
	return top_card

##
func connect_card_signals(card):
	card.connect("mouse_on", card_hover_on)
	card.connect("mouse_off", card_hover_off)

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

#func connect_tile_signals(tile):
	#tile.connect("mouse_over_tile", tile_range_on)
	#tile.connect("mouse_off_tile", tile_range_off)
#
#func tile_range_on(_tile):
	#flip_zone += 1
#
#func tile_range_off(_tile):
	#flip_zone -= 1

func highlight_card(card, hovering):
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
		
func animate_card(card, new_scale, pos):
	if tweening and tweening.is_running():
		await tweening.finished
	tweening = get_tree().create_tween()
	if !card.in_tile:
		tweening.parallel().tween_property(card, "position", card.deck_pos + pos, 0.08)
	tweening.parallel().tween_property(card, "scale", new_scale, 0.08)
