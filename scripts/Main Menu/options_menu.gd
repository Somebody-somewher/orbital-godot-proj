extends Control
class_name OptionMenu



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func animate(entering : bool) -> void:
	if entering:
		get_node("AnimationPlayer").play("enter")
	else:
		get_node("AnimationPlayer").play("exit")
