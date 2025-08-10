extends MenuTab
class_name GameSettingMenuTab

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interpret_round_slider(int(rounds_hslider.value))
	score = int(min_score + score_hslider.value * 10)
	
	board_size_grp = ButtonGroup.new()
	button_8.button_group = board_size_grp
	button_16.button_group = board_size_grp
	button_32.button_group = board_size_grp
	pass

######### WIN CONDITIONS CODE ##################
@export var rounds_label : Label
@export var rounds_hslider : Slider
var min_rounds : int = 2
var no_rounds : int = -1
var inf_rounds: bool = false
func _on_round_slider_value_changed(value: float) -> void:
	no_rounds = int(value * 0.49 + 2)
	rounds_label.text = str(no_rounds)
	interpret_round_slider(int(value))

func interpret_round_slider(value : int) -> void:
	if value == 100:
		inf_rounds = true
		rounds_label.text = "infinity"
		no_rounds = -1
	else:
		inf_rounds = false

@export var scores_label: Label
@export var score_hslider : Slider
var min_score : int = 100 # if == 0, means no aura selection rounds
var score = min_score
func _on_score_slider_value_changed(value: float) -> void:
	score = min_score
	score = int(min_score + value * 10)
	scores_label.text = str(score)

	if value == 100:
		score = -1
		scores_label.text = "infinity"

########## GENERATION OPTIONS CODE ##################
@export var button_8 : BaseButton
@export var button_16 : BaseButton
@export var button_32 : BaseButton
var board_size_grp : ButtonGroup
#@export var board_size_grp : ButtonGroup
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
#func board_size_changed():
	#board_size = _what_board_size()
 
# Alternatively use envmapping to get default then each entry make a button
var terrain_types : Dictionary[String, bool] = {"Grass" : true, "Desert" : true, "Water" : true}

func _on_grass_toggled(toggled_on: bool) -> void:
	terrain_types["Grass"] = toggled_on

func _on_water_toggled(toggled_on: bool) -> void:
	terrain_types["Water"] = toggled_on
	pass # Replace with function body.

func _on_sand_toggled(toggled_on: bool) -> void:
	terrain_types["Desert"] = toggled_on
	pass # Replace with function body.

var terrain_grp : ButtonGroup
func _on_terrain_toggled(toggled_on: bool) -> void:
	var pressed = terrain_grp.get_pressed_button()
	#var button := get_called_instance() as Button
	#terrain_types.set(terrain, toggled_on)

@export var spawnable_label: Label
var spawnables : bool = true

func _on_spawnables_button_toggled(toggled_on: bool) -> void:
	spawnables = toggled_on
	if toggled_on:
		spawnable_label.text = "On"
	else:
		spawnable_label.text = "Off"

@export var build_phase_time_text: Label
@export var build_phase_time_slider : Slider
@export var max_build_phase_time_text := 120
var build_phase_time : int = 45 # if == 0, means no aura selection rounds
func _on_buildtime_slider_value_changed(value: float) -> void:
	build_phase_time = int(value)
	build_phase_time_text.text = str(build_phase_time)

	if value == max_build_phase_time_text + 1:
		build_phase_time = -1
		build_phase_time_text.text = "infinity"
		
@export var packchoose_phase_time_text: Label
@export var packchoose_phase_time_slider : Slider
@export var max_packchoose_phase_time_text := 80
var packchoose_phase_time : int = 20 # if == 0, means no aura selection rounds
func _on_packchoose_slider_value_changed(value: float) -> void:
	packchoose_phase_time = int(value)
	packchoose_phase_time_text.text = str(packchoose_phase_time)

	if value == max_packchoose_phase_time_text + 1:
		packchoose_phase_time = -1
		packchoose_phase_time_text.text = "infinity"

@export var terrain_mapping : EnvTerrainMapping
# As a dict in case we need to rpc this later
func get_game_settings() -> Dictionary:
	var dict_output : Dictionary = {}
	dict_output["win_rounds"] = no_rounds
	dict_output["win_score"] = score
	dict_output["board_size"] = _what_board_size()
	
	var terrain_output = []
	for terrain in terrain_types:
		if terrain_types[terrain]:
			terrain_output.append(terrain_mapping.getTileDatabyId(terrain))
	
	dict_output['procgen'] = {}
	dict_output['procgen']["terrain_types"] = terrain_output
	
	if !spawnables:
		dict_output['procgen']['terrain_spawnables'] = spawnables
	
	dict_output['build_time'] = build_phase_time
	dict_output['pickpack_time'] = packchoose_phase_time
	return dict_output
