extends Board
class_name MenuBoard

@onready var card_manager_ref: CardManager = $"../CardManager"
@onready var player_hand_ref: Node2D = $"../PlayerHand"
@onready var menu_logic_ref: MenuLogic = $"../MenuLogic"
@onready var timer: Timer = $Timer
var menu_state = "main_menu"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	self.position = Vector2(get_viewport().size.x/2 - TILE_SIZE/2, 400)

func place_building_on_tile(placeable : PlaceableNode, tile_pos : Vector2i) -> void:
	super.place_building_on_tile(placeable, tile_pos)
	player_hand_ref.discard_hand()
	menu_state = menu_logic_ref.select_option(menu_state, placeable.data.id_name)
	
	timer.start()

func spawn_hand(state_name: String) -> void:
	var arr = menu_logic_ref.get_hand(state_name)
	for id in arr:
		spawn_card(id)

# for add cards back into hand
func spawn_card(id_name : String) -> void:
	var new_card = MenuCard.new_card(id_name)
	new_card.position = get_global_tile_pos(Vector2i(0,0))
	card_manager_ref.add_child(new_card)
	new_card.connect_to_card_manager(card_manager_ref)
	player_hand_ref.add_to_hand(new_card)

func _on_timer_timeout() -> void:
	board_matrix.get_tile(Vector2i(0,0)).clear_tile()
	spawn_hand(menu_state)
