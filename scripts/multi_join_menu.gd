extends MenuTab
class_name MultiJoinMenu

var lobby : LobbyLogic

@export var ip_textbox : TextEdit
@export var port_textbox : TextEdit
@export var name_textbox : TextEdit 
@export var players_list : Label 
@export var join_btn : Button

func _ready() -> void:
	lobby = NetworkManager.get_node("Lobby")
	lobby.set_up_client(ip_textbox, port_textbox, name_textbox, players_list)

######### SOUND OPTIONS CODE ##################

@onready var master_label: Label = $SettingsTabs/RightTab/TabContainer/Sound/MarginContainer/VBoxContainer/MasterBox/Label2
@onready var music_label: Label = $SettingsTabs/RightTab/TabContainer/Sound/MarginContainer/VBoxContainer/MusicBox/Label2
@onready var sfx_label: Label = $SettingsTabs/RightTab/TabContainer/Sound/MarginContainer/VBoxContainer/SFXBox/Label2

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
	
func _on_join_pressed() -> void:
	lobby.on_join_pressed()
	pass # Replace with function body.
