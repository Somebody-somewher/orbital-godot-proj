extends Node2D

signal left_mouse_click
signal left_mouse_released
signal right_mouse_click
signal right_mouse_released

const CARD_COLLISION_MASK = 1
const TILE_COLLISION_MASK = 2
const BUILDING_COLLISION_MASK = 4
const PACK_COLLISION_MASK = 8
const SET_COLLISION_MASK = 16

enum InputType {LEFT_CLICK, RIGHT_CLICK}

var rng = RandomNumberGenerator.new()

@onready var camera_ref: Camera2D = $"../Camera2D"

var MASKS := {
	"all" : 0xFFFFFFFF,
	"set_only" : 0x00000010,
	"pack_only" : 0x00000008
}

var curr_mask := 0xFFFFFFFF

func _input(event):
	# If it helps Project Settings already has an Input Map for the leftmousebutton btw 
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if event.pressed:
					raycast_and_click(curr_mask, InputType.LEFT_CLICK)
				else:
					emit_signal("left_mouse_released")
			MOUSE_BUTTON_RIGHT:
				if event.pressed:
					raycast_and_click(curr_mask, InputType.RIGHT_CLICK)
				else:
					emit_signal("right_mouse_released")
			MOUSE_BUTTON_WHEEL_DOWN:
				if event.pressed:
					camera_ref.zoom_cam(false)
			MOUSE_BUTTON_WHEEL_UP:
				if event.pressed:
					camera_ref.zoom_cam(true)

func left_click_logic(result) -> void:
	var result_mask = result.collider.collision_mask
	var result_found = result.collider.get_parent()
	match result_mask:
		CARD_COLLISION_MASK:
			if result_found.dissolving:
				return
			play_click(.7)
			var card_manager = result_found.get_parent()
			card_manager.start_drag(result_found)
		PACK_COLLISION_MASK:
			var card_manager = result_found.get_parent()
			card_manager.start_drag(result_found)
		SET_COLLISION_MASK:
			var pack = result_found.get_parent()
			pack.select_option(result_found)
			curr_mask = MASKS.get("all")
		BUILDING_COLLISION_MASK:
			result_found.get_node("JiggleAnimation").play("jiggle")

func right_click_logic(result) -> void:
	var result_mask = result.collider.collision_mask
	var result_found = result.collider.get_parent()
	match result_mask:
		CARD_COLLISION_MASK:
			var card_manager = result_found.get_parent()
			card_manager.finish_drag(false)
		PACK_COLLISION_MASK:
			result_found.open_pack()
			var card_manager = result_found.get_parent()
			card_manager.finish_drag(false)
			if !result_found is MenuPack:
				curr_mask = MASKS.get("set_only")

func raycast_and_click(mask, input_type : int):
	var space_state : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	
	# returns arr of id of objects clicked on
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	params.collision_mask = mask 
	var result = space_state.intersect_point(params)
	if result.size() <= 0 :
		if input_type == InputType.LEFT_CLICK:
				camera_ref.start_camera_drag()
		return
	result = topmost(result)
	match input_type:
		InputType.LEFT_CLICK:
			left_click_logic(result)
		InputType.RIGHT_CLICK:
			right_click_logic(result)

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

func play_click(pitch : float):
	self.get_node("ClickAudio").pitch_scale = pitch
	self.get_node("ClickAudio").play()
	
