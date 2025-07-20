extends Control
class_name DeprecatedSingleplayerMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func animate(entering : bool) -> void:
	if entering:
		get_node("AnimationPlayer").play("enter")
	else:
		get_node("AnimationPlayer").play("exit")

######### ROUND OPTIONS CODE ##################

@onready var rounds_label = $"SettingsTabs/LeftTab/TabContainer/Round Settings/MarginContainer/VBoxContainer/RoundsBox/Label2"
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

@onready var aura_freq_label: Label = $"SettingsTabs/LeftTab/TabContainer/Round Settings/MarginContainer/VBoxContainer/AuraFeqBox/Label2"
var aura_freq : int = 1 # if == 0, means no aura selection rounds
func _on_aura_freq_slider_value_changed(value: float) -> void:
	aura_freq = int(value * 0.1)
	if aura_freq == 0:
		aura_freq_label.text = "never"
	elif aura_freq == 1:
		aura_freq_label.text = "/round"
	else:
		aura_freq_label.text = "/" + str(aura_freq) + " rnds"

@onready var sabo_label: Label = $"SettingsTabs/LeftTab/TabContainer/Round Settings/MarginContainer/VBoxContainer/SaboBox/Label2"
var sabotage : bool = true
func _on_sabo_button_toggled(toggled_on: bool) -> void:
	sabotage = toggled_on
	if toggled_on:
		sabo_label.text = "On"
	else:
		sabo_label.text = "Off"

######### DIFFICULTY OPTIONS CODE ##################

@onready var pnt_scale_label: Label = $SettingsTabs/LeftTab/TabContainer/Difficulty/MarginContainer/VBoxContainer/PointScaleBox/Label2
var point_scale : float = 1.0
func _on_pnt_scale_slider_value_changed(value: float) -> void:
	point_scale = number_slider_scale(value, pnt_scale_label)
	

@onready var goal_label: Label = $SettingsTabs/LeftTab/TabContainer/Difficulty/MarginContainer/VBoxContainer/ThreshholdBox/Label2
var goal_scale : float = 1.0
func _on_goal_slider_value_changed(value: float) -> void:
	goal_scale = number_slider_scale(value, goal_label)

func number_slider_scale(value : float, label : Label) -> float:
	var final_val : float
	if value == 0:
		final_val = 0.25
	elif value <= 20:
		final_val = 0.5
	elif value <= 40:
		final_val = 0.75
	elif value <= 60:
		final_val = 1
	elif value <= 80:
		final_val = 2
	elif value < 100:
		final_val = 4
	else:
		final_val = 8
	label.text = str(final_val) + "x"
	if value > 40:
		label.text = str(int(final_val)) + "x"
	return final_val

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
