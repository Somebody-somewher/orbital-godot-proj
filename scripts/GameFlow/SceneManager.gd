extends Node

static var is_gameplay_paused := false
static var is_everything_paused := false

@export var MENU : PackedScene = preload("res://scenes/Main Menu/main_menu.tscn")
@export var GAME : PackedScene = preload("res://scenes/Main.tscn")

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

@rpc("any_peer", "call_local")
func start_game() -> void:
	get_tree().change_scene_to_packed(GAME)
	curr_scene = "game"
	
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
