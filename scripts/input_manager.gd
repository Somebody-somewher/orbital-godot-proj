extends Node2D

signal left_mouse_click
signal left_mouse_released

const CARD_COLLISION_MASK = 1
const TILE_COLLISION_MASK = 2
const FLIP_COLLISION_MASK = 4 ##detect if card should flip over and transform into structure
const PACK_COLLISION_MASK = 8
const SET_COLLISION_MASK = 16

@onready
var card_manager = $"../CardManager"

func _input(event):
	# If it helps Project Settings already has an Input Map for the leftmousebutton btw 
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("left_mouse_click")
			raycast_cursor(0xFFFFFFFB)
		else:
			emit_signal("left_mouse_released")

func raycast_cursor(mask):
	var space_state : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	
	# returns id of objects clicked on
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	params.collision_mask = mask 
	var result = space_state.intersect_point(params)
	
	if result.size() > 0 :
		result = topmost(result)
		var result_mask = result.collider.collision_mask
		match result_mask:
			CARD_COLLISION_MASK:
				var card_found = result.collider.get_parent()
				if card_found:
					card_found.get_parent().start_drag(card_found)
			PACK_COLLISION_MASK:
				var pack_found = result.collider.get_parent()
				if pack_found:
					pack_found.open_pack()
			SET_COLLISION_MASK:
				var set_found = result.collider.get_parent()
				if set_found:
					var pack = set_found.get_parent()
					pack.select_option(set_found)


# from arr selects topmost node
func topmost(result_arr):
	var top = result_arr[0]
	var max_z = top.collider.get_parent().z_index
	
	for i in range (1, result_arr.size()):
		var current = result_arr[i]
		if current.collider.get_parent().z_index > max_z:
			top = current
			max_z = current.collider.get_parent().z_index
	return top
