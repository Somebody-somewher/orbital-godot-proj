extends Control

@onready
var menu_logic = $MenuLogic

@onready var title_menu: TitleMenu = $Menus/TitleMenu
@onready var options_menu: OptionMenu = $Menus/OptionsMenu
@onready var singleplayer_menu: GameSettingMenuTab = $Menus/SingleplayerMenu
@onready var multiplayer_menu: MultiplayerMenu = $Menus/MultiplayerMenu
@onready var multi_host_menu: MultiHostMenu = $Menus/HostMenu
@onready var multi_join_menu: MultiJoinMenu = $Menus/JoinMenu
@onready var input_manager: Node2D = $InputManager
@onready var camera_2d: Camera2D = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title_menu.visible = true
	options_menu.visible = false
	singleplayer_menu.visible = false
	multiplayer_menu.visible = false
	input_manager.camera_enabled = false
	multi_host_menu.visible = false
	multi_join_menu.visible = false	
	camera_2d.cam_enabled = false
	connect_signals()
	
	AudioManager.play_bgm("menu")
	AudioManager.next_bgm = "menu"

func connect_signals() -> void:
	menu_logic.setting_menu_open.connect(on_open_settings)
	menu_logic.setting_menu_exit.connect(on_close_settings)
	menu_logic.singleplayer_open.connect(on_open_singleplayer)
	menu_logic.singleplayer_back.connect(on_close_singleplayer)
	menu_logic.multiplayer_open.connect(on_open_multiplayer)
	menu_logic.multiplayer_back.connect(on_close_multiplayer)
	menu_logic.exit_game.connect(on_exit_game)
	menu_logic.start_singleplayer_game.connect(on_start_singleplayer)
	menu_logic.multihost_open.connect(on_open_host)
	menu_logic.multihost_back.connect(on_close_host)
	menu_logic.start_multiplayer_game.connect(on_start_multiplayer)
	menu_logic.multijoin_open.connect(on_open_join)
	menu_logic.multijoin_back.connect(on_close_join)

func on_open_settings() -> void:
	options_menu.sync_settings()
	
	title_menu.animate(false)
	options_menu.animate(true)

func on_close_settings() -> void:
	options_menu.animate(false)
	title_menu.animate(true)

func on_open_singleplayer() -> void:
	title_menu.animate(false)
	singleplayer_menu.animate(true)

func on_close_singleplayer() -> void:
	singleplayer_menu.animate(false)
	title_menu.animate(true)

func on_open_multiplayer() -> void:
	title_menu.animate(false)
	multiplayer_menu.animate(true)

func on_close_multiplayer() -> void:
	multiplayer_menu.animate(false)
	title_menu.animate(true)

func on_open_host():
	multi_host_menu.sync_vol_sliders()
	multiplayer_menu.animate(false)
	multi_host_menu.animate(true)

func on_close_host():
	multiplayer_menu.animate(true)
	multi_host_menu.animate(false)
	#NetworkManager.get_node("Lobby").menu_leave_lobby()

func on_open_join():
	multi_join_menu.sync_vol_sliders()
	multiplayer_menu.animate(false)
	multi_join_menu.animate(true)

func on_close_join():
	multiplayer_menu.animate(true)
	multi_join_menu.animate(false)
	#NetworkManager.get_node("Lobby").menu_leave_lobby()

func on_start_multiplayer():
	initialize_game.rpc(multi_host_menu.get_game_settings())

func on_start_singleplayer() -> void:
	initialize_game(singleplayer_menu.get_game_settings())

func on_exit_game() -> void:
	get_tree().quit()

@rpc("any_peer", "call_local")
func initialize_game(settings : Dictionary) -> void:
	NetworkManager.set_up()
	SceneManager.start_game()
