extends Node

@export var MENU : PackedScene = preload("res://scenes/Main Menu/main_menu.tscn")
@export var GAME : PackedScene = preload("res://scenes/Main.tscn")

var curr_scene : String

func back_to_menu() -> void:
	reset_components()
	get_tree().change_scene_to_packed(MENU)
	curr_scene = "menu"

func start_game() -> void:
	get_tree().change_scene_to_packed(GAME)
	curr_scene = "game"

func reset_components() -> void:
	PlayerManager.reset()
	AudioManager.stop_bgm()
	NetworkManager.full_reset()
	CardLoader.reset()
