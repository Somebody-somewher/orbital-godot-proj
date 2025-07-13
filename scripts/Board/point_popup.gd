extends Node2D
class_name PointPopUp

var start_pos : Vector2 = Vector2.ZERO
var points : int = 1

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	global_position = start_pos
	label.text = "+" + str(points)
	animation_player.play("pop")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
