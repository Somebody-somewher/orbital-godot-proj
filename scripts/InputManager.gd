# InputManager autoload
# Idea is that Cards -> InputManager
# InputManager find which card is ontop via z-axis
# CardManager is connected to clicked signal of InputManager
# CardManager reads the stiring attached to clicked signal, if matching, does card_drag

extends Node

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

func node_clicked(node : Node2D, sig: String):
	clicked_objects.append([node,sig])

# from arr selects topmost node
func topmost(result_arr) -> Array:
	var top = result_arr[0]
	var max_z = top[0].z_index
	
	for i in range (1, result_arr.size()):
		var current = result_arr[i]
		if current[0].z_index > max_z:
			top = current
			max_z = current[0].z_index
	return top
