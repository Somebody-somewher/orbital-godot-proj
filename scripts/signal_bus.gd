extends Node


# ROUND LOGIC
signal end_turn(player_uuid : String)
signal round_end(round_id : String, round_total : int)
signal round_start(round_id : String, round_total : int)

signal round_timer_update(curr_time : int)

# SCORE LOGIC
signal add_score(score_to_add : int, player_uuid : String)
signal update_score_ui(score : int)

# sends to board to spawn card
signal spawn_card(id : String, pos : Vector2)

# CARDPACK
signal server_create_packs()
signal create_pack(packs_of_cards : Array)

# Pack Choosing
signal server_update_chooser(pack_ids : Array[int])

# CardPack -> CardPackManagerClient 
signal choose_pack(pack_index : int)

signal server_pack_choosing_end()

# Hand_related
signal confirmed_add_to_hand(cards : Array[String])
signal remove_from_hand(card : CardInstanceData)
signal add_to_hand(card : Card)

signal register_to_cardmanager(card : Card)

################ BOARD ################
#signal run_func_on_board(c : Callable)
signal get_matrix_data()

# Supply board_tile_positions_data with [[tile_pos], [tile_data]]  
signal get_tile_pos_from_AOE(tile_pos : Vector2i, aoe_tiles : Array[Vector2i], board_tile_positions_data : Array[Vector2i])
signal mouse_enter_interactable_board_tile()
signal mouse_enter_board()

signal place_placeable(pi : PlaceableInstanceData, tile_pos : Vector2i, player_uuid : String, run_on_place_events : bool, sync : bool)
#server_place_newplaceable(pi : PlaceableInstanceData, tile_pos : Vector2i, player_uuid : String, run_on_place_events := true, sync := true)


signal board_action_result(outcome : bool)
signal set_score_preview(tile_pos : Array[Vector2i], scores : Array[int])

################ COMPENDIUM ############################
signal show_card_information(card_id : String)
signal open_compendium(card_id : String)
signal close_compendium

signal notif_msg(msg : String)

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
# UI MESSAGES
signal show_error_msg(msg : String)
signal show_round_msg(msg : String)

signal end_game(winner_uuid : String, player_scores : Dictionary[String, Dictionary])

# FX
signal show_fx(id : String, pos : Vector2)
signal show_point_fx(score : int, pos : Vector2)


signal change_input_mask(mask)
signal pause_input
signal resume_input

# EventManager
#signal trigger_effect(bid : BuildingInstanceData, effect_type : Sting)
