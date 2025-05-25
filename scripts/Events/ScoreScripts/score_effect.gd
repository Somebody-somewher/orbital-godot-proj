extends BoardEvent
class_name ScoreEffect

var lazy_score : int

signal AddScore(score: int)

# Calls the board tiles directly to display the score
# any tiles that are called to display must be set in baord's affected tiles (as Array[Vector2i])
# this is so that the board can clear only affected tiles and not the whole board
func calculate_and_display_scoring(id_name : String, board : Board, tile_pos : Vector2i) -> void:
	pass

func signal_add_score(score : int) :
	AddScore.emit(score)
