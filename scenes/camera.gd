extends Camera2D

@export var board: BoardVisualManager
@onready var player_hand: PlayerHand = $"../PlayerHand"
@onready var card_manager: CardManager = $"../CardManager"

var cam_enabled = true

var screen_size : Vector2
var camera_dragged := false
var drag_offset := Vector2.ZERO
var mouse_initial := Vector2.ZERO

var _target_zoom := 1.0
const MIN_ZOOM := 0.5
const MAX_ZOOM := 4.0
const ZOOM_INC := 0.1
const ZOOM_RATE := 8.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport().size
	position = player_hand.position + screen_size/2

#for zooming only
func _physics_process(delta: float) -> void:
	zoom = lerp(zoom, _target_zoom * Vector2.ONE, ZOOM_RATE * delta)
	var zoom_ratio = player_hand.zoom_var /zoom.x
	player_hand.pos_offset = player_hand.pos_offset + screen_size/player_hand.zoom_var/2 *(1 - zoom_ratio)
	if card_manager.card_dragged is Card:
		card_manager.card_dragged.deck_scale = 1/zoom.x
	player_hand.zoom_var = zoom.x
	player_hand.snap_to_hand_pos()
	set_physics_process(not is_equal_approx(zoom.x, _target_zoom))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !cam_enabled:
		return
	if !camera_dragged:
		var delta_pos =  restrict_camera_to_board()
		if not (is_equal_approx(delta_pos.x, 0) and is_equal_approx(delta_pos.y, 0)):
			global_position -= delta_pos
			player_hand.pos_offset -= delta_pos
			player_hand.snap_to_hand_pos()
		return
	if Input.is_action_just_released("leftMouseClick"):
		finish_camera_drag()
	else:
		var mouse_delta = mouse_initial - get_viewport().get_mouse_position()
		var new_pos = mouse_delta/zoom + drag_offset - mouse_initial/zoom
		global_position = new_pos + screen_size/2/zoom
		player_hand.pos_offset = new_pos
		player_hand.snap_to_hand_pos()

func start_camera_drag() -> void:
	card_manager.hover_enabled = false
	drag_offset = get_global_mouse_position()
	mouse_initial = get_viewport().get_mouse_position()
	camera_dragged = true

func finish_camera_drag() -> void:
	camera_dragged = false
	card_manager.hover_enabled = true
	card_manager.card_hover_if_able()

func zoom_cam(out: bool) -> void:
	if out:
		_target_zoom = min(_target_zoom + ZOOM_INC, MAX_ZOOM)
	else:
		_target_zoom = max(_target_zoom - ZOOM_INC, MIN_ZOOM)
	set_physics_process(true)

# returns the vector required to adjust camera back to near board
func restrict_camera_to_board() -> Vector2:
	var minXY = board.get_board_coords()[0] + screen_size/zoom/5
	var maxXY = board.get_board_coords()[1] + screen_size/zoom/5
	var clamped_x = clamp(global_position.x, minXY.x,maxXY.x)
	var clamped_y = clamp(global_position.y, minXY.y,maxXY.y)
	return (global_position - Vector2(clamped_x, clamped_y)) * 0.3
