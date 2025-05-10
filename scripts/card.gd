extends Node2D

signal mouse_on
signal mouse_off

var deck_angle = 0
var deck_pos
var in_tile = false

##shader stuff
@onready
var sprite_ref = $CardImage
var dissolving = false
var dissolve_value = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	##Boardmanager should be first child of root
	get_tree().root.get_child(0).get_node("CardManager").connect_card_signals(self) 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dissolving:
		if dissolve_value > 0:
			sprite_ref.material.set_shader_parameter("DissolveValue", dissolve_value)
			dissolve_value -= delta * 1.6
		else:
			sprite_ref.visible = false
			free()


func _on_area_2d_mouse_entered() -> void:
	emit_signal("mouse_on", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("mouse_off", self)
