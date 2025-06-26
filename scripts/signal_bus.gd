extends Node


# ROUND LOGIC
signal end_turn()
signal round_end(round_id : int, round_total : int)
signal round_start(round_id : int, round_total : int)
signal round_timer_update(curr_time : int)

# SCORE LOGIC
signal cache_score(score : int)
signal add_score(score_to_add : int)
signal update_score_ui(score : int)

# BOARD
#signal run_func_on_board(c : Callable)
# sends to board to spawn card
signal spawn_card(id : String, pos : Vector2)

# CARDPACK
signal server_create_packs()
signal create_pack(packs_of_cards : Array)

# Pack Choosing
signal server_update_chooser(num_packs : int)

# CardPack -> CardPackManagerClient 
signal choose_pack(pack_index : int)

signal server_pack_choosing_end()

# Adding to hand
signal confirmed_add_to_hand(cards : Array[String], set_id : int)
signal add_to_hand(card : Card)

signal register_to_cardmanager(card : Card)

# Supply board_tile_positions_data with [[tile_pos], [tile_data]]  
signal get_tile_pos_from_AOE(tile_pos : Vector2i, aoe_tiles : Array[Vector2i], board_tile_positions_data : Array[Vector2i])
signal mouse_enter_interactable_board_tile()
signal mouse_enter_board()

signal board_action_fail()
signal board_action_success()

# For Pathfinding for boats, Floodfill for castle
signal run_search_on_board(c : Callable)

signal set_score_preview(tile_pos : Array[Vector2i], scores : Array[int])

# COMPENDIUM
signal show_card_information(card_id : String)
signal open_compendium(card_id : String)
signal close_compendium

@rpc("any_peer", "call_local")
func emit_multiplayer_signal(signal_to_call : String, args : Array):
	
	match args.size():
		0:
			emit_signal(signal_to_call)
		1:
			emit_signal(signal_to_call, args[0])
		2:
			emit_signal(signal_to_call, args[0], args[1])
		3:
			emit_signal(signal_to_call, args[0], args[1], args[2])
		_:
			assert(1 == 0)
