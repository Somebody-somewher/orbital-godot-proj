extends Node2D
class_name FXManager

@export var fx_dict : Dictionary[String, PackedScene]
@export var point_fx : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signalbus.connect("show_fx", show_fx)
	Signalbus.connect("show_point_fx", show_point_fx)

#displays the fx on the board at pos
func show_fx(id : String, pos : Vector2):
	var fx_scene = fx_dict.get(id).instantiate()
	fx_scene.start_pos = pos
	add_child(fx_scene)

func show_point_fx(score : int, pos : Vector2):
	var fx_scene = point_fx.instantiate()
	fx_scene.start_pos = pos
	fx_scene.points = score
	add_child(fx_scene)
