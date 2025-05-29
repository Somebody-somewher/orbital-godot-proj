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

#signal request_board_state()
