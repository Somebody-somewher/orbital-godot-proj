extends BoardEvent
class_name ScoreEffect

var lazy_score : int

signal AddScore(score: int)

func calculate_and_display_scoring(id_name : String, board : Board, tile_pos : Vector2i) -> void:
	pass

func signal_add_score(score : int) :
	AddScore.emit(score)
