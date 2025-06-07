extends Resource
class_name Condition

# Pop-up msg explain to the user why they cant place the placeable or why something is happenin?
@export_multiline var reminder_msg : String

var return_bool := true

func test(_board : Board, _tile_pos : Vector2i) -> bool:
	return return_bool
