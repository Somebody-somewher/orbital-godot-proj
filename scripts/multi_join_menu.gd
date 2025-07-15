extends Control
class_name MultiJoinMenu

var lobby : LobbyLogic

@onready var ip_textbox : TextEdit = $SettingsTabs/LeftTab/TabContainer/Joining/MarginContainer/VBoxContainer/VBoxContainer/AddressBox/TextEdit
@onready var port_textbox : TextEdit = $SettingsTabs/LeftTab/TabContainer/Joining/MarginContainer/VBoxContainer/VBoxContainer/Port/TextEdit
@onready var name_textbox : TextEdit = $SettingsTabs/LeftTab/TabContainer/Joining/MarginContainer/VBoxContainer/VBoxContainer/Namebox/TextEdit
@onready var players_list : Label = $SettingsTabs/LeftTab/TabContainer/Joining/MarginContainer/VBoxContainer/PlayersBox/ScrollContainer/Playerlist
@onready var join_btn : Button = $SettingsTabs/LeftTab/TabContainer/Joining/MarginContainer/VBoxContainer/VBoxContainer/AddressBox/join

func _ready() -> void:
	lobby = NetworkManager.get_node("Lobby")
	lobby.set_up_client(ip_textbox, port_textbox, name_textbox, players_list)
	join_btn.pressed.connect(lobby.on_join_pressed)
	
func animate(entering : bool) -> void:
	if entering:
		get_node("AnimationPlayer").play("enter")
	else:
		get_node("AnimationPlayer").play("exit")

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

func _on_sfx_slider_drag_ended(value_changed: bool) -> void:
	AudioManager.play_sfx("grass")

func _on_master_slider_value_changed(value: float) -> void:
	master_label.text = str(int(value))
	AudioManager.change_master_volume(value/100)
	
