extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var matrix : Array[Array] = [[1,2,3,4,5,6],[7,8,9,10,11,12],[13,14,15,16,17,18],[19,20,21,22,23,24]] 
	print(matrix)
	var z = ProcGenBoardIterator.new(matrix, Vector2i(2,2), Vector2i(1,1), Vector2i(2,1))
	#while z.next_board():
		#z.foreach_tile(print)
	z.foreach_border(print)

	
	pass # Replace with function body.
