extends BoardManagerBare
class_name MenuBoard

@onready var menu_logic_ref: MenuLogic = $"../MenuLogic"
@onready var timer: Timer = $Timer
var menu_state = "main_menu"

var selected_pid : String
var selected_pos : Vector2i
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	terrain_tilemap.set_cell(Vector2i(0,0), 0, Vector2i(0,1), 0)
	under_tilemap.set_cell(Vector2i(0,0), 0, Vector2i(1,1), 1)
	self.position = Vector2(800 - terrain_tilemap.TILE_SIZE/2, 400)
	Signalbus.connect("board_action_result", _on_attempt_place)

func place_cardplaceable(placeable_id : String, tile_pos : Vector2i = NULL_TILE) -> void:
	selected_pid = placeable_id
	super.place_cardplaceable(placeable_id, tile_pos)

func _on_attempt_place(result: bool):
	if result:
		AudioManager.play_sfx("grass")
		menu_state = menu_logic_ref.select_option(menu_state, selected_pid)
		if menu_state != "start_game":
			timer.start()

func _on_timer_timeout() -> void:
	clear_tile(selected_pid, Vector2i(0,0))
	menu_logic_ref.get_hand(menu_state)
