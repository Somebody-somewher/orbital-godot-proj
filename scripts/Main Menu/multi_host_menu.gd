extends GameSettingMenuTab
class_name MultiHostMenu

var lobby : LobbyLogic

@export var name_textbox : TextEdit
@export var players_list : Label 

func _ready() -> void:
	lobby = NetworkManager.get_node("Lobby")
	lobby.set_up_host(name_textbox, players_list)
	super._ready()

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

func _on_host_pressed() -> void:
	lobby.on_host_pressed()
	pass # Replace with function body.
