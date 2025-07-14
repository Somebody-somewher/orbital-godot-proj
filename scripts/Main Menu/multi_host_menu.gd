extends Control
class_name MultiHostMenu

func animate(entering : bool) -> void:
	if entering:
		get_node("AnimationPlayer").play("enter")
	else:
		get_node("AnimationPlayer").play("exit")

######### ROUND OPTIONS CODE ##################

@onready var rounds_label = $SettingsTabs/RightTab/TabContainer/Rounds/MarginContainer/VBoxContainer/RoundsBox/Label2
var no_rounds : int = 2
var inf_rounds: bool = false
func _on_round_slider_value_changed(value: float) -> void:
	no_rounds = int(value * 0.49 + 2)
	rounds_label.text = str(no_rounds)
	if value == 100:
		inf_rounds = true
		rounds_label.text = "infinity"
	else:
		inf_rounds = false

@onready var aura_freq_label: Label = $SettingsTabs/RightTab/TabContainer/Rounds/MarginContainer/VBoxContainer/AuraFeqBox/Label2
var aura_freq : int = 1 # if == 0, means no aura selection rounds
func _on_aura_freq_slider_value_changed(value: float) -> void:
	aura_freq = int(value * 0.1)
	if aura_freq == 0:
		aura_freq_label.text = "never"
	elif aura_freq == 1:
		aura_freq_label.text = "/round"
	else:
		aura_freq_label.text = "/" + str(aura_freq) + " rnds"

@onready var sabo_label: Label = $SettingsTabs/RightTab/TabContainer/Rounds/MarginContainer/VBoxContainer/SaboBox/Label2
var sabotage : bool = true
func _on_sabo_button_toggled(toggled_on: bool) -> void:
	sabotage = toggled_on
	if toggled_on:
		sabo_label.text = "On"
	else:
		sabo_label.text = "Off"


######### GENERATION OPTIONS CODE ##################
@export var board_size_grp : ButtonGroup
var board_size : int = 8

func _what_board_size():
	var pressed = board_size_grp.get_pressed_button()
	match pressed.name:
		"8":
			return 8
		"16":
			return 16
		"32":
			return 32

func board_size_changed():
	board_size = _what_board_size()
 
var terrain_types : Dictionary[String, bool] = {"grass" : true, "water" : true,"sand" : true}

func _on_terrain_toggled(toggled_on: bool, terrain: String) -> void:
	terrain_types.set(terrain, toggled_on)

@onready var spawnable_label: Label = $SettingsTabs/RightTab/TabContainer/Generation/MarginContainer/VBoxContainer/SpawnableBox/Label2
var spawnables : bool = true

func _on_spawnables_button_toggled(toggled_on: bool) -> void:
	spawnables = toggled_on
	if toggled_on:
		spawnable_label.text = "On"
	else:
		spawnable_label.text = "Off"

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
	
