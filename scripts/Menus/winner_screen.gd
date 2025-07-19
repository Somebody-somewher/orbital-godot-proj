extends Control
class_name WinnerScreen

#players in the format name, score, medals
var players : Array = [["example_name", 1000, 3], ["example_name", 200, 1], ["example_name", 400, 6]]
var pillars : Array[PodiumPillar]

@onready var pillar_container: HBoxContainer = $MarginContainer/Pillars
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var pillar_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	preprocess()
	#await get_tree().create_timer(1).timeout
	#display()

func display() -> void:
	start_anim()

# calculates and add the winner flag and target y to the players
func preprocess() -> void:
	var max_score := 0
	var max_medal := 0
	for player in players:
		max_score = max(max_score, player[1])
		max_medal = max(max_medal, player[2])
	
	for player in players:
		player.append(player[2] == max_medal)
		player.append(-610 * (float(player[1])/max_score))
		create_pillar(player)

func create_pillar(player : Array) -> void:
	var new_pillar : PodiumPillar = pillar_scene.instantiate()
	new_pillar.player_name = player[0]
	new_pillar.score = player[1]
	new_pillar.medals = player[2]
	new_pillar.winner = player[3]
	new_pillar.target_y = player[4]
	pillars.append(new_pillar)
	pillar_container.add_child(new_pillar)

func start_anim():
	animation_player.play("popup")

func _on_popped(anim_name: StringName) -> void:
	print(players)
	for p in pillars:
		p.start_process()
