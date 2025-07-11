#extends BoardManagerBare
#class_name MenuBoard
#
#@onready var card_manager_ref: CardManager = $"../CardManager"
#@onready var player_hand_ref: Node2D = $"../PlayerHand"
#@onready var menu_logic_ref: MenuLogic = $"../MenuLogic"
#@onready var timer: Timer = $Timer
#var menu_state = "main_menu"
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#proc_gen = null
	#super._ready()
	#self.position = Vector2(get_viewport().size.x/2 - terrain_tilemap.TILE_SIZE/2, 400)
#
#func place_on_board_if_able(pid : String, tile_pos : Vector2i = Vector2i(-1,-1)) -> bool:
	#var result = super.place_on_board_if_able(pid, tile_pos)
	#if result:
		#player_hand_ref.discard_hand()
		#menu_state = menu_logic_ref.select_option(menu_state, pid)
		#
		#timer.start()
	#return result
#
### Checks if any of the interactable boards are being hovered over 
#func is_mouse_near_interactable_board() -> bool:
	#return true
#
#func spawn_hand(state_name: String) -> void:
	#var arr = menu_logic_ref.get_hand(state_name)
	#for id in arr:
		#spawn_card(id)
#
## for add cards back into hand
#func spawn_card(id_name : String) -> void:
	#var new_card = MenuCard.new_card(id_name)
	#new_card.global_position = Vector2i(800,450)
	#card_manager_ref.add_child(new_card)
	#card_manager_ref.connect_card_signals(new_card)
	#player_hand_ref.add_to_hand(new_card)
#
#func _on_timer_timeout() -> void:
	#matrix_data.get_tile(Vector2i(0,0)).clear_tile()
	#spawn_hand(menu_state)
