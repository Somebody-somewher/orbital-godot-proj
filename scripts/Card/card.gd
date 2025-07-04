extends Node2D
class_name Card

signal mouse_on
signal mouse_off

#for constructor
static var card_scene: PackedScene = load("res://scenes/Card/Card.tscn")

# for differentiating player vs eligible board to be played on
var owner_id : int

#animation vars for player hand
var deck_angle = 0
var deck_pos = Vector2.ZERO
var deck_scale := 1.0

##shader stuff
@onready
var sprite_ref = self
var dissolving = false
var dissolve_value = 1
var enable_3d = false
var foiled = false

# name to find references in database
var id_name : String = "cute_dummy"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if foiled:
		self.material.set_shader_parameter("effect_alpha_mult",1)
	else:
		self.material.set_shader_parameter("effect_alpha_mult",0)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dissolving:
		get_node("Texts").visible = false
		if dissolve_value > 0:
			sprite_ref.material.set_shader_parameter("dissolve_value", dissolve_value)
			dissolve_value -= delta * 1.6
		else:
			sprite_ref.visible = false
			queue_free()

	self.material.set_shader_parameter("mouse_position",get_global_mouse_position())
	self.material.set_shader_parameter("sprite_position",global_position)
	if enable_3d:
		self.material.set_shader_parameter("max_tilt",0.5)
	else:
		self.material.set_shader_parameter("max_tilt",0.01)
	


func dissolve_card() -> void:
	get_node("Area2D/CollisionShape2D").disabled = true
	dissolving = true

## OVERWRITE BELOW IN CHILD CLASSES
######################################################################

# called when added to player hand
func initialize_card_effect() -> void:
	pass

# called when added to board
# fully replace card with effect, then free self instance
func swap_to_effect(scale_by: Vector2) -> void:
	self.get_node("Area2D/CollisionShape2D").disabled = true
	dissolve_card()

#called by cardmanager when highlighting
func highlight_card(on : bool, tweening : Tween) -> void :
	pass
######################################################################

func _on_area_2d_mouse_entered() -> void:
	emit_signal("mouse_on", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("mouse_off", self)

func card_flip_to_entity() -> void:
	get_node("FlipAnimation").play("card_flip_to_entity")

func entity_flip_to_card() -> void:
	get_node("FlipAnimation").play("entity_flip_to_card")
