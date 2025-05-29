extends Node

signal end_turn()
signal round_end(round_id : int, round_total : int)
signal round_start(round_id : int, round_total : int)
signal round_timer_update(curr_time : int)

signal cache_score(score : int,)
signal add_score()

#signal request_board_state()
