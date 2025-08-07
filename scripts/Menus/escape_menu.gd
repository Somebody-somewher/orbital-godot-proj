extends Control
class_name EscapeMenu

var enabled := true
var open_state : bool = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer

############# LOBBY OPTIONS ###############
@onready var sure_box: VBoxContainer = $LeftTab/TabContainer/Lobby/MarginContainer/VBoxContainer/SureBox
@export var main_menu : PackedScene

func _on_back_pressed() -> void:
	close_menu()

func _on_leave_pressed() -> void:
	sure_box.visible = true

func _on_confirm_leave_pressed() -> void:
	SceneManager.back_to_menu()

func _on_stay_pressed() -> void:
	sure_box.visible = false

######### SOUND OPTIONS CODE ##################
@onready var master_label: Label = $LeftTab/TabContainer/Settings/MarginContainer/VBoxContainer/MasterBox/Label2
@onready var music_label: Label = $LeftTab/TabContainer/Settings/MarginContainer/VBoxContainer/MusicBox/Label2
@onready var sfx_label: Label = $LeftTab/TabContainer/Settings/MarginContainer/VBoxContainer/SFXBox/Label2

@onready var master_slider: HSlider = $LeftTab/TabContainer/Settings/MarginContainer/VBoxContainer/MasterBox/HSlider
@onready var music_slider: HSlider = $LeftTab/TabContainer/Settings/MarginContainer/VBoxContainer/MusicBox/HSlider
@onready var sfx_slider: HSlider = $LeftTab/TabContainer/Settings/MarginContainer/VBoxContainer/SFXBox/HSlider

func _on_music_slider_value_changed(value: float) -> void:
	music_label.text = str(int(value))
	AudioManager.change_bgm_volume(value/100)

func _on_sfx_slider_value_changed(value: float) -> void:
	sfx_label.text = str(int(value))
	AudioManager.sfx_volume = value/100

func _on_sfx_slider_drag_ended(_value_changed: bool) -> void:
	AudioManager.play_sfx("grass")

func _on_master_slider_value_changed(value: float) -> void:
	master_label.text = str(int(value))
	AudioManager.change_master_volume(value/100)

func sync_vol_sliders():
	master_slider.value = AudioManager.master_volume * 100
	music_slider.value = AudioManager.bgm_volume * 100 / 0.6
	sfx_slider.value = AudioManager.sfx_volume * 100
	

########## GRAPHICS OPTIONS #######################
@onready var fullscreen_button: Button = $LeftTab/TabContainer/Settings/MarginContainer/VBoxContainer/FullscreenBox/Button


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sync_vol_sliders()
	sure_box.visible = false
	Signalbus.enable_escape.connect(set_enable)

func set_enable(on : bool):
	enabled = on

func close_menu() -> void:
	open_state = false
	sure_box.visible = false
	animation_player.play("close")
	Signalbus.resume_input.emit()
	

func open_menu() ->void:
	if !enabled:
		return
	open_state = true	
	fullscreen_button.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	sure_box.visible = false
	animation_player.play("open")
	Signalbus.pause_input.emit()
	Signalbus.tut_escape_menu_opened.emit()

func toggle() -> void:
	if open_state:
		close_menu()
	else:
		open_menu()
