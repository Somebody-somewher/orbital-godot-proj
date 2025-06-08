extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var matrix : Array[Array] = [[0, 1, 2, 3, 4, 5, 6, 7], [8, 9, 10, 11, 12, 13, 14, 15], [16, 17, 18, 19, 20, 21, 22, 23], [24, 25, 26, 27, 28, 29, 30, 31], [32, 33, 34, 35, 36, 37, 38, 39], [40, 41, 42, 43, 44, 45, 46, 47]]
	#print(matrix)
	var z = ProcGenBoardIterator.new(matrix, Vector2i(2,2), Vector2i(2,2), Vector2i(2,1))
	while z.next_board():
		z.foreach_tile_in_board(print)
		print("NEXT BOARD\n")
	z.foreach_border(print)

	
	pass # Replace with function body.
