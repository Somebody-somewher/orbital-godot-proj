extends Node2D
class_name PointPopUp

var start_pos : Vector2 = Vector2.ZERO
var end_pos : Vector2
var points : int = 1

@onready var label: Label = $Node2D/Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true
	position = start_pos + Vector2(0, -50)
	if !end_pos:
		end_pos = start_pos
	label.text = "+" + str(points)
	animation_player.play("pop")
	await get_tree().create_timer(.6).timeout
	var tweening = get_tree().create_tween()
	tweening.tween_property(self, "position", end_pos + Vector2(0, -50), 0.3)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
