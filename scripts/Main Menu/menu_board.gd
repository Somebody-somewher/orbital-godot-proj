extends Board
class_name MenuBoard

@onready var card_manager_ref: CardManager = $"../CardManager"
@onready var player_hand_ref: Node2D = $"../PlayerHand"
@onready var menu_logic_ref: MenuLogic = $"../MenuLogic"
@onready var timer: Timer = $Timer


var menu_state = "main_menu"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	BOARD_SIZE = 1
	BOARD_SCALE = 0.15
	
	# Update the positioning of the tilemaps
	env_map.scale = Vector2(BOARD_SCALE, BOARD_SCALE)
	env_map.z_index = -1
	env_map.tile_set = environment.tileset

	highlight_map.scale = Vector2(BOARD_SCALE, BOARD_SCALE)
	highlight_map.tile_set = environment.tileset
	
	TILE_SIZE = env_map.tile_set.tile_size.x * BOARD_SCALE
	board_coord = [Vector2(0,0), TILE_SIZE * Vector2.ONE * (BOARD_SIZE)] 
	self.position = Vector2(get_viewport().size.x/2 - TILE_SIZE/2, 400)
	board_matrix = Array()
	board_matrix.resize(1)
	board_matrix[0] = Array()
	board_matrix[0].resize(1)
		
	env_map.set_cell(Vector2(0,0), 0, Vector2(0,0), 0)
	var board_tile = BoardTile.new(environment.getTileDatabyId("grass"), get_global_tile_pos(Vector2(0,0)))
	board_tile.score_display = Label.new()
	board_matrix[0][0] = board_tile

func place_building_on_tile(tile_pos : Vector2i, building: Building) -> void:
	add_child(building)
	board_matrix[0][0].add_building(building)
	building.position = tilecoords_to_localpos(tile_pos)
	building.get_node("JiggleAnimation").play("jiggle")
	player_hand_ref.discard_hand()
	menu_state = menu_logic_ref.select_option(menu_state, building.id_name)
	
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
	get_tile(Vector2i(0,0)).clear_tile()
	spawn_hand(menu_state)
