extends Object
class_name BoardLayout

static func get_board_layout(num_players : int) -> Vector2i:
	match num_players:
		2:
			return Vector2i(2,1)
		3:
			return Vector2i(2,2)
		4:
			return Vector2i(2,2)
		_:
			# Get the minimal number of tiles in a rectangular format
			for i in range(floor(sqrt(num_players)),0,-1):
				if num_players % i == 0:
					return Vector2i(i, num_players / i) 
	return Vector2i(1,1)
