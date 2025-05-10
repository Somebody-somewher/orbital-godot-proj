extends Node2D

# Position of where the board is created on screen
@export var spawn_pos = Vector2(200,100)
const tile_size = 82 #pixel width of one tile

# Length/Width (no. cells) of board
@export var BOARD_SIZE = 5
@export var BOARD_SCALE = 1.5
var board_coord = [spawn_pos, spawn_pos + Vector2(tile_size, tile_size) * (BOARD_SIZE-1) * BOARD_SCALE] #top left tile and bottom right tile
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

# Initialize 2d array matrix
func initialise_array() -> void:
	board_matrix=Array()
	board_matrix.resize(BOARD_SIZE);
	for i in range(BOARD_SIZE):
		board_matrix[i]=Array()
		board_matrix[i].resize(BOARD_SIZE)
		for j in range(BOARD_SIZE):
			board_matrix[i][j] = spawn_tile(i, j)

func spawn_tile(i, j) -> Node2D:
	var tile_instance = tile.instantiate()
	tile_instance.position = spawn_pos + Vector2(i * tile_size * BOARD_SCALE, j * tile_size * BOARD_SCALE)
	
	# Different colouration for every alternate tile
	if (i + j) % 2 == 0:
		tile_instance.get_node("Sprite2D").texture = grass_dark
	tile_instance.scale = tile_instance.scale * BOARD_SCALE
	add_child(tile_instance)
	return tile_instance

func mouse_near_board(mouse_pos):
	const THRESHOLD = 150
	if mouse_pos.x > board_coord[0].x - THRESHOLD and mouse_pos.x < board_coord[1].x + THRESHOLD:
		return mouse_pos.y > board_coord[0].y - THRESHOLD and mouse_pos.y < board_coord[1].y + THRESHOLD
