extends MenuTab
class_name OptionMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
		
######### SOUND OPTIONS CODE ##################

@onready var master_label: Label = $SettingsTabs/LeftTab/TabContainer/Sound/MarginContainer/VBoxContainer/MasterBox/Label2
@onready var music_label: Label = $SettingsTabs/LeftTab/TabContainer/Sound/MarginContainer/VBoxContainer/MusicBox/Label2
@onready var sfx_label: Label = $SettingsTabs/LeftTab/TabContainer/Sound/MarginContainer/VBoxContainer/SFXBox/Label2

@onready var master_slider: HSlider = $SettingsTabs/LeftTab/TabContainer/Sound/MarginContainer/VBoxContainer/MasterBox/HSlider
@onready var music_slider: HSlider = $SettingsTabs/LeftTab/TabContainer/Sound/MarginContainer/VBoxContainer/MusicBox/HSlider
@onready var sfx_slider: HSlider = $SettingsTabs/LeftTab/TabContainer/Sound/MarginContainer/VBoxContainer/SFXBox/HSlider


func _on_music_slider_value_changed(value: float) -> void:
	music_label.text = str(int(value))
	AudioManager.change_bgm_volume(value/100)

func _on_sfx_slider_value_changed(value: float) -> void:
	sfx_label.text = str(int(value))
	AudioManager.change_sfx_volume(value/100)

func _on_sfx_slider_drag_ended(_value_changed: bool) -> void:
	AudioManager.play_sfx("grass")

func _on_master_slider_value_changed(value: float) -> void:
	master_label.text = str(int(value))
	AudioManager.change_master_volume(value/100)

func sync_settings():
	master_slider.value = AudioManager.master_volume * 100
	music_slider.value = AudioManager.bgm_volume * 100 / 0.6
	sfx_slider.value = AudioManager.sfx_volume * 100
	
	fullscreen_button.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN

########## GRAPHICS OPTIONS #######################
@onready var fullscreen_button: Button = $SettingsTabs/RightTab/TabContainer/Graphics/MarginContainer/VBoxContainer/FullscreenBox/Button


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
