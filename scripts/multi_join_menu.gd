extends Control
class_name MultiJoinMenu
	
func animate(entering : bool) -> void:
	if entering:
		get_node("AnimationPlayer").play("enter")
	else:
		get_node("AnimationPlayer").play("exit")

######### NETWORKING CODE #####################
@onready var ip_field: TextEdit = $SettingsTabs/LeftTab/TabContainer/Joining/MarginContainer/VBoxContainer/VBoxContainer/AddressBox/TextEdit
@onready var name_field: TextEdit = $SettingsTabs/LeftTab/TabContainer/Joining/MarginContainer/VBoxContainer/VBoxContainer/Namebox/TextEdit
@onready var playerlist: Label = $SettingsTabs/LeftTab/TabContainer/Joining/MarginContainer/VBoxContainer/PlayersBox/ScrollContainer/Playerlist

func _on_join_pressed() -> void:
	pass # Replace with function body.


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
	
