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
signal server_pack_choosing_end()
signal select_pack(pack_id : int)

# Supply board_tile_positions_data with [[tile_pos], [tile_data]]  
signal get_tile_pos_from_AOE(tile_pos : Vector2i, aoe_tiles : Array[Vector2i], board_tile_positions_data : Array[Vector2i])
signal mouse_enter_interactable_board_tile()
signal mouse_enter_board()

# For Pathfinding for boats, Floodfill for castle
signal run_search_on_board(c : Callable)

signal set_score_preview(tile_pos : Array[Vector2i], scores : Array[int])

# COMPENDIUM
signal show_card_information(card_id : String)
signal open_compendium(card_id : String)
signal close_compendium
