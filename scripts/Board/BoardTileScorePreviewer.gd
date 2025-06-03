extends Object
class_name BoardTileScorePreviewer

var BOARD_SIZE : int

var tile_score_matrix

var displayed_labels : Array[Label] 
var label_parent : Node2D


func _init(parent : Node2D, get_global : Callable, board_size : int) -> void:
	BOARD_SIZE = board_size
	tile_score_matrix = Array()
	tile_score_matrix.resize(BOARD_SIZE)
	label_parent = parent
	Signalbus.connect("set_score_preview", display_tile_scores)
	
	for row in range(BOARD_SIZE):
		tile_score_matrix[row] = Array()
		tile_score_matrix[row].resize(BOARD_SIZE)
		
		# tile score display (can be extracted to a function)
		for col in range(BOARD_SIZE):
			tile_score_matrix[row][col] = add_tile_label(get_global.call(Vector2i(row,col)))
	

func add_tile_label(global_tile_pos : Vector2) -> Label:
	var score_label = Label.new()
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.theme = preload("res://assets/fonts/cutey_card_theme.tres")
	#score_label.set("theme_override_colors/font_color",Color(0,0.0,0.0,1.0))
	score_label.set("theme_override_colors/font_color", Color.YELLOW)
	score_label.set("theme_override_font_sizes/font_size",30)
	score_label.z_index = 9
	score_label.visible = false
	label_parent.add_child(score_label)
	score_label.global_position = global_tile_pos - score_label.size/2 + Vector2(0,-50)
	return score_label
	
func display_tile_scores(tile_positions : Array[Vector2i], scores : Array[int]):
	assert(len(tile_positions) == len(scores))
	var label : Label
	for i in range(len(tile_positions)):
		if scores[i] != 0:
			label = tile_score_matrix[tile_positions[i].x][tile_positions[i].y]
			label.set_text(str(scores[i]))
			label.set_visible(true)
			displayed_labels.append(label)

func reset_display():
	for l in displayed_labels:
		l.set_text("0")
		l.set_visible(false)
