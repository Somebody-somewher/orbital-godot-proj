extends Control
class_name MenuTab

func animate(entering : bool) -> void:
	if entering:
		get_node("AnimationPlayer").play("enter")
	else:
		get_node("AnimationPlayer").play("exit")
