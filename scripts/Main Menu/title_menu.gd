extends Control
class_name TitleMenu

@onready var camera_2d: Camera2D = $"../../Camera2D"

func animate(entering : bool) -> void:
	camera_2d.centre()
	if entering:
		visible = true
		get_node("AnimationPlayer").play("enter")
		set_process(true)
	else:
		set_process(false)
		get_node("AnimationPlayer").play("exit")
		visible = false
