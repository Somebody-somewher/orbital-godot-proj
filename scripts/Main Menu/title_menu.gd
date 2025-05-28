extends Control
class_name TitleMenu

func animate(entering : bool) -> void:
	if entering:
		visible = true
		get_node("AnimationPlayer").play("enter")
		set_process(true)
	else:
		set_process(false)
		get_node("AnimationPlayer").play("exit")
		visible = false
