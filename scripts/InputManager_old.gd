# InputManager autoload
# Idea is that Cards -> InputManager
# InputManager find which card is ontop via z-axis
# CardManager is connected to clicked signal of InputManager
# CardManager reads the stiring attached to clicked signal, if matching, does card_drag

extends Node2D

signal clicked

# Array of ClickableNode<->String Pair
# The string is the function we want to call
var clicked_objects : Array[Array]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !clicked_objects.is_empty():
		var top_node : Array = topmost(clicked_objects)
		emit_signal("clicked", topmost(clicked_objects)[0], topmost(clicked_objects)[1])
		
	clicked_objects.clear()

func node_clicked(node : Node2D, sig: String):
	clicked_objects.append([node,sig])

func select_raycast(mask) -> Node2D:
	var space_state : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state 
	
	# returns id of objects clicked on
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	params.collision_mask = mask
	var result : Array[Dictionary] = space_state.intersect_point(params)
	
	if !result.is_empty():
		return topmost_obj_frm_collider(result)
		
	return null
	

# from arr selects topmost node
func topmost(result_arr : Array[Array]) -> Array:
	var top = result_arr[0]
	var max_z = top[0].z_index
	
	for i in range (1, result_arr.size()):
		var current = result_arr[i]
		if current[0].z_index > max_z:
			top = current
			max_z = current[0].z_index
	return top

func topmost_obj_frm_collider(colliders : Array[Dictionary]) -> Node2D:
	var top_obj : Node2D = colliders[0].collider.get_parent()
	var max_z : int = top_obj.z_index
	
	# Finds the card that has the z-value, 
	# return that as the top-card
	for i in range (1, colliders.size()):
		var current : Node2D = colliders[i].collider.get_parent()
		if current.z_index > max_z:
			top_obj = current
			max_z = current.z_index
	return top_obj
