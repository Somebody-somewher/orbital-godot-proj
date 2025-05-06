extends Node2D

var card_dragged
var card_hovered
var screen_size

const CARD_COLLISION_MASK = 1
const TILE_COLLISION_MASK = 2
const FLIP_COLLISION_MASK = 3 ##detect if card should flip over and transform into structure
const CARD_EASE = 0.1

func _ready() -> void:
	screen_size = get_viewport_rect().size
	

func _process(delta: float) -> void:
	if card_dragged:
		var mouse_pos = get_global_mouse_position()
		var new_x = (mouse_pos.x - card_dragged.position.x) * CARD_EASE + card_dragged.position.x
		var new_y = (mouse_pos.y - card_dragged.position.y) * CARD_EASE + card_dragged.position.y
		card_dragged.position = Vector2(clamp(new_x, 0, screen_size.x), clamp(new_y, 0, screen_size.y))


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = select_raycast(CARD_COLLISION_MASK)
			if card:
				start_drag(card)
		else:
			if card_dragged:
				finish_drag()

func start_drag(card):
	card_dragged = card
	
	var tile_check = select_raycast(TILE_COLLISION_MASK)
	if tile_check:
		tile_check.tile_built = false
	
	if !card_hovered:
		highlight_card(card, true)
		card_hovered = card
	##card.get_parent().move_child(card, -1)

func finish_drag():
	if card_hovered: ##plonks the card down
		highlight_card(card_hovered, false)
		card_hovered = null
	##check if dragged into a tile
	var tile_check = select_raycast(TILE_COLLISION_MASK)
	if tile_check and !tile_check.tile_built:
		card_dragged.position = tile_check.position
		tile_check.tile_built = true
		##card_dragged.get_node("Area2D/CollisionShape2D").disabled = true
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
			

func highlight_card(card, hovering):
	if hovering:
		card.scale = Vector2(card.CARD_SIZE * 1.05, card.CARD_SIZE * 1.05)
		card.get_parent().move_child(card, -1)
		card.z_index = 2
	else:
		card.scale = Vector2(card.CARD_SIZE, card.CARD_SIZE)
		card.z_index = 1
		
