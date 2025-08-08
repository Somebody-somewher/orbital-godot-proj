extends Node

static var is_gameplay_paused := false
static var is_everything_paused := false

@export var MENU : PackedScene = preload("res://scenes/Main Menu/main_menu.tscn")
@export var GAME : PackedScene = preload("res://scenes/Main.tscn")
@export var TUTORIAL : PackedScene = preload("res://scenes/Tutorial/tutorial.tscn")

var curr_scene : String = "menu"

func _ready() -> void:
	Signalbus.server_create_packs.connect(pause_gameplay)
	Signalbus.server_pack_choosing_end.connect(unpause_gameplay)

@rpc("any_peer", "call_local")
func back_to_menu() -> void:
	reset_components()
	get_tree().change_scene_to_packed(MENU)
	curr_scene = "menu"
	unpause_gameplay()

func tut_back_to_menu() -> void:
	NetworkManager.full_reset()
	CardLoader.reset()
	Signalbus.reset_scene.emit()
	get_tree().change_scene_to_packed(MENU)
	unpause_everything()
	unpause_gameplay()
	curr_scene = "menu"

@rpc("any_peer", "call_local")
func start_game(settings : Dictionary = {}) -> void:
	await get_tree().change_scene_to_packed(GAME)
	#if !settings.is_empty():
	await get_tree().process_frame  # Wait for scene change to start
	await get_tree().process_frame  # Wait for scene fully initialized
	(get_tree().current_scene as GameManager).setup(settings)
	curr_scene = "game"

@rpc("any_peer", "call_local")
func start_tutorial() -> void:
	await get_tree().change_scene_to_packed(TUTORIAL)
	#if !settings.is_empty():
	await get_tree().process_frame  # Wait for scene change to start
	await get_tree().process_frame  # Wait for scene fully initialized
	(get_tree().current_scene).setup(get_tut_settings())
	curr_scene = "tutorial"
	
func reset_components() -> void:
	AudioManager.stop_bgm()
	unpause_everything()
	NetworkManager.full_reset()
	CardLoader.reset()
	Signalbus.reset_scene.emit()

@rpc("any_peer", "call_local")
func pause_gameplay() -> void:
	_set_pause_gameplay(true)

@rpc("any_peer", "call_local")
func unpause_gameplay() -> void:
	_set_pause_gameplay(false)

@rpc("any_peer", "call_local")
func pause_everything() -> void:
	is_everything_paused = true
	_set_pause_gameplay(true)

@rpc("any_peer", "call_local")
func unpause_everything() -> void:
	is_everything_paused = false
	_set_pause_gameplay(false)

func _set_pause_gameplay(setting : bool) -> void:
	is_gameplay_paused = setting

func get_tut_settings() -> Dictionary:
	var board_settings = {}
	var procgen_settings = {}
	var temp_arr = []
	temp_arr.append(load("res://Resources/EnvTerrain/TerrainTiles/Grass.tres"))
	procgen_settings.set("terrain_types", temp_arr)
	procgen_settings.set("terrain_spawnables", false)
	board_settings.set("procgen", procgen_settings)
	board_settings.set("board_size", 3)
	board_settings.set("build_time", 10000)
	board_settings.set("pickpack_time", 10000)
	return board_settings
