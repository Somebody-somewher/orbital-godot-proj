extends Control
class_name PodiumPillar

#set by contructor
@export var player_name : String = "player_name"
@export var score : int = 4000
var medals : int = 3
var winner := false
var target_y : float = -610

#internals
var text_score : int = 0
var _time_elapse : float = 0
var win_flag = false

@onready var name_label: Label = $Center/VBoxContainer/Name
@onready var score_label: Label = $Center/VBoxContainer/Score
@onready var medal_container: HBoxContainer = $Center/VBoxContainer/PillarText/MarginContainer/MedalContainer

@export var medal_scene : PackedScene

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var win_rays: TextureRect = $Center/VBoxContainer/Name/win_rays

func _ready() -> void:
	position.y = 0
	for i in range(medals):
		medal_container.add_child(medal_scene.instantiate())
	name_label.text = player_name
	score_label.text = "0"
	set_process(false)

func start_process() -> void:
	set_process(true)

func win_first_time():
	animation_player.play("win")
	win_flag = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if text_score < score:
		_time_elapse = min(_time_elapse + delta, 4)
		text_score = score * (_time_elapse/4)
		score_label.text = str(text_score)
		position.y = lerp(position.y, target_y, delta)
	else:
		if winner:
			if !win_flag:
				win_first_time()
			win_rays.rotation_degrees += delta * 15
		else:
			set_process(false)
		
