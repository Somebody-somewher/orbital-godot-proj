extends Resource
class_name ProcGenPostBase

func process(matrix, xlen : int, ylen : int) -> void:
	for x in range(xlen):
		for y in range(ylen):
			process_per_tile(matrix[x][y])
	pass

func process_per_tile(tile_contents : Array) -> void:
	pass
