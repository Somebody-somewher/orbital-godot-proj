extends MenuTab
class_name GameSettingMenuTab

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

######### WIN CONDITIONS CODE ##################
@export var rounds_label : Label
var no_rounds : int = 2
var inf_rounds: bool = false
func _on_round_slider_value_changed(value: float) -> void:
	no_rounds = int(value * 0.49 + 2)
	rounds_label.text = str(no_rounds)
	if value == 100:
		inf_rounds = true
		rounds_label.text = "infinity"
		no_rounds = -1
	else:
		inf_rounds = false

@export var scores_label: Label 
var min_score : int = 100 # if == 0, means no aura selection rounds
var score = 0
func _on_score_slider_value_changed(value: float) -> void:
	score = min_score
	score = int(min_score + value * 10)
	scores_label.text = str(score)

	if value == 100:
		score = -1
		scores_label.text = "infinity"


#@onready var aura_freq_label: Label = $SettingsTabs/RightTab/TabContainer/Rounds/MarginContainer/VBoxContainer/AuraFeqBox/Label2
#var aura_freq : int = 1 # if == 0, means no aura selection rounds
#func _on_aura_freq_slider_value_changed(value: float) -> void:
	#aura_freq = int(value * 0.1)
	#if aura_freq == 0:
		#aura_freq_label.text = "never"
	#elif aura_freq == 1:
		#aura_freq_label.text = "/round"
	#else:
		#aura_freq_label.text = "/" + str(aura_freq) + " rnds"
#
#@onready var sabo_label: Label = $SettingsTabs/RightTab/TabContainer/Rounds/MarginContainer/VBoxContainer/SaboBox/Label2
#var sabotage : bool = true
#func _on_sabo_button_toggled(toggled_on: bool) -> void:
	#sabotage = toggled_on
	#if toggled_on:
		#sabo_label.text = "On"
	#else:
		#sabo_label.text = "Off"
######### DIFFICULTY OPTIONS CODE ##################

#func number_slider_scale(value : float, label : Label) -> float:
	#var final_val : float
	#if value == 0:
		#final_val = 0.25
	#elif value <= 20:
		#final_val = 0.5
	#elif value <= 40:
		#final_val = 0.75
	#elif value <= 60:
		#final_val = 1
	#elif value <= 80:
		#final_val = 2
	#elif value < 100:
		#final_val = 4
	#else:
		#final_val = 8
	#label.text = str(final_val) + "x"
	#if value > 40:
		#label.text = str(int(final_val)) + "x"
	#return final_val
#
########## GENERATION OPTIONS CODE ##################
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
#
func board_size_changed():
	board_size = _what_board_size()
 
# Alternatively use envmapping to get default then each entry make a button
var terrain_types : Dictionary[String, bool] = {"grass" : true, "water" : true,"sand" : true}

func _on_terrain_toggled(toggled_on: bool, terrain: String) -> void:
	terrain_types.set(terrain, toggled_on)
#
@export var spawnable_label: Label
var spawnables : bool = true

func _on_spawnables_button_toggled(toggled_on: bool) -> void:
	spawnables = toggled_on
	if toggled_on:
		spawnable_label.text = "On"
	else:
		spawnable_label.text = "Off"

# As a dict in case we need to rpc this later
func get_game_settings() -> Dictionary:
	var dict_output : Dictionary = {}
	dict_output["win_rounds"] = no_rounds
	dict_output["win_score"] = score
	dict_output["board_size"] = board_size
	dict_output['terrain_types'] = terrain_types
	dict_output['terrain_spawnables'] = spawnables
	return dict_output
