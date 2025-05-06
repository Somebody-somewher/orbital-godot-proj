extends Node2D

const spawn_pos = Vector2(200,100)
const tile_size = 84
const BOARD_SIZE = 5
var board_matrix


var grass_light = preload("res://sprites/grass.png")
var grass_dark = preload("res://sprites/grass_dark.png")

var tile = preload("res://scenes/board_tile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialise_array()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initialise_array():
	board_matrix=Array()
	board_matrix.resize(BOARD_SIZE);
	for i in range(BOARD_SIZE):
		board_matrix[i]=Array()
		board_matrix[i].resize(BOARD_SIZE)
		for j in range(BOARD_SIZE):
			board_matrix[i][j] = spawn_tile(i, j)

func spawn_tile(i, j):
	var tile_instance = tile.instantiate()
	add_child(tile_instance)
	tile_instance.position = spawn_pos + Vector2(i * tile_size, j * tile_size)
	if (i + j) % 2 == 0:
		tile_instance.get_node("Sprite2D").texture = grass_dark
	
	return tile_instance
