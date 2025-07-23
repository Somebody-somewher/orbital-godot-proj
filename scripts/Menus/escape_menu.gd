extends Control
class_name EscapeMenu

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
@onready var master_label: Label = $LeftTab/TabContainer/Sound/MarginContainer/VBoxContainer/MasterBox/Label2
@onready var music_label: Label = $LeftTab/TabContainer/Sound/MarginContainer/VBoxContainer/MusicBox/Label2
@onready var sfx_label: Label = $LeftTab/TabContainer/Sound/MarginContainer/VBoxContainer/SFXBox/Label2

@onready var master_slider: HSlider = $LeftTab/TabContainer/Sound/MarginContainer/VBoxContainer/MasterBox/HSlider
@onready var music_slider: HSlider = $LeftTab/TabContainer/Sound/MarginContainer/VBoxContainer/MusicBox/HSlider
@onready var sfx_slider: HSlider = $LeftTab/TabContainer/Sound/MarginContainer/VBoxContainer/SFXBox/HSlider

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sync_vol_sliders()
	sure_box.visible = false

func close_menu() -> void:
	open_state = false
	sure_box.visible = false
	animation_player.play("close")
	Signalbus.resume_input.emit()
	

func open_menu() ->void:
	open_state = true
	sure_box.visible = false
	animation_player.play("open")
	Signalbus.pause_input.emit()

func toggle() -> void:
	if open_state:
		close_menu()
	else:
		open_menu()
