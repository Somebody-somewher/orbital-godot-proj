extends Node2D
class_name InputManager

signal left_mouse_released
signal right_mouse_released

const CARD_COLLISION_MASK = 1
const TILE_COLLISION_MASK = 2
const BUILDING_COLLISION_MASK = 4
const PACK_COLLISION_MASK = 8
const SET_COLLISION_MASK = 16
const COMPENDIUM_COLLISION_MASK = 32

enum InputType {LEFT_CLICK, RIGHT_CLICK, MIDDLE_CLICK}

@onready var camera_ref: Camera2D = $"../Camera2D"
var camera_enabled := true

var MASKS := {
	"none" : 0x00000000,
	"all" : 0xFFFFFFFF,
	"set_only" : 0x00000010,
	"pack_only" : 0x00000008
}

var paused_mask
var curr_mask := 0xFFFFFFFF

func _input(event):
	# If it helps Project Settings already has an Input Map for the leftmousebutton btw 
	if event is InputEventMouseButton and !SceneManager.is_everything_paused:
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
			MOUSE_BUTTON_MIDDLE:
				if event.pressed:
					raycast_and_click(curr_mask, InputType.MIDDLE_CLICK)
			MOUSE_BUTTON_WHEEL_DOWN:
				if event.pressed and camera_enabled:
					camera_ref.zoom_cam(false)
			MOUSE_BUTTON_WHEEL_UP:
				if event.pressed and camera_enabled:
					camera_ref.zoom_cam(true)

func left_click_logic(result) -> void:
	var result_mask = result.collision_mask
	var result_found = result.get_parent()
	AudioManager.play_sfx("click", 0.7)
	match result_mask:
		CARD_COLLISION_MASK:
			if result_found.dissolving:
				return
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
		COMPENDIUM_COLLISION_MASK:
			Signalbus.open_compendium.emit("")
			#curr_mask = MASKS.get("none")

func right_click_logic(result) -> void:
	var result_mask = result.collision_mask
	var result_found = result.get_parent()
	match result_mask:
		CARD_COLLISION_MASK:
			var card_manager = result_found.get_parent()
			card_manager.finish_drag(false)
		PACK_COLLISION_MASK:
			AudioManager.play_sfx("click", 0.5)
			if result_found.choose_or_open():
				curr_mask = MASKS.get("set_only")
			
			var card_manager = result_found.get_parent()
			card_manager.finish_drag(false)

func middle_click_logic(result) -> void:
	var result_mask = result.collision_mask
	var result_found = result.get_parent()
	match result_mask:
		CARD_COLLISION_MASK:
			var card_manager = result_found.get_parent()
			card_manager.highlight_card(result_found, false)
			#TODO : Remember to fix this once id_name is running
			var name = result_found.something
			print(name)
			Signalbus.open_compendium.emit(name)
		BUILDING_COLLISION_MASK:
			var name = result_found.data_instance.id_name
			Signalbus.open_compendium.emit(name)

func raycast_and_click(mask, input_type : int):
	var space_state : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	
	# returns arr of id of objects clicked on
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	params.collision_mask = mask 
	var result = space_state.intersect_point(params)
	if result.size() <= 0 :
		if input_type == InputType.LEFT_CLICK and camera_enabled:
				camera_ref.start_camera_drag()
		return
	result = topmost(result).collider
	match input_type:
		InputType.LEFT_CLICK:
			left_click_logic(result)
		InputType.RIGHT_CLICK:
			right_click_logic(result)
		InputType.MIDDLE_CLICK:
			middle_click_logic(result)

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

func _ready() -> void:
	Signalbus.connect("open_compendium", open_compendium)
	Signalbus.connect("close_compendium", close_compendium)
	Signalbus.connect("change_input_mask", change_input_mask)
	Signalbus.connect("pause_input", pause_input)
	Signalbus.connect("resume_input", resume_input)
	

func open_compendium(_id : String):
	curr_mask = MASKS.get("none")
	camera_enabled = false

func close_compendium():
	curr_mask = MASKS.get("all")
	camera_enabled = true
	
func change_input_mask(mask):
	curr_mask = mask

func pause_input():
	camera_enabled = false
	paused_mask = curr_mask
	curr_mask = MASKS.get("none")

func resume_input():
	curr_mask = paused_mask
	camera_enabled = true
