extends Control

@onready
var menu_logic = $MenuLogic

const MAIN = preload("res://scenes/Main.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect_signals()

func connect_signals() -> void:
	menu_logic.setting_menu_open.connect(on_open_settings)
	menu_logic.setting_menu_exit.connect(on_close_settings)
	menu_logic.singleplayer_open.connect(on_open_singleplayer)
	menu_logic.singleplayer_back.connect(on_close_singleplayer)
	menu_logic.multiplayer_open.connect(on_open_multiplayer)
	menu_logic.multiplayer_back.connect(on_close_multiplayer)
	menu_logic.exit_game.connect(on_exit_game)
	menu_logic.start_singleplayer_game.connect(on_start_singleplayer)

func on_open_settings() -> void:
	pass

func on_close_settings() -> void:
	pass

func on_open_singleplayer() -> void:
	pass

func on_close_singleplayer() -> void:
	pass

func on_open_multiplayer() -> void:
	pass

func on_close_multiplayer() -> void:
	pass

func on_start_singleplayer() -> void:
	get_tree().change_scene_to_packed(MAIN)

func on_exit_game() -> void:
	get_tree().quit()
