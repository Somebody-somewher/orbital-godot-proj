extends Node

@export var MENU : PackedScene = preload("res://scenes/Main Menu/main_menu.tscn")
@export var GAME : PackedScene = preload("res://scenes/Main.tscn")

func back_to_menu() -> void:
	reset_components()
	get_tree().change_scene_to_packed(MENU)

func start_to_game() -> void:
	get_tree().change_scene_to_packed(GAME)

func reset_components() -> void:
	PlayerManager.reset()
	AudioManager.stop_bgm()
	NetworkManager.full_reset()
	CardLoader.reset()
