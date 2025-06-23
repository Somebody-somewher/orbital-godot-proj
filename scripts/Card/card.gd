extends Node2D
class_name Card

signal mouse_on
signal mouse_off

@export var card_image : Texture2D
var cardinstance_dataid : String
#for constructor
static var card_scene: PackedScene = load("res://scenes/Card/Card.tscn")

#animation vars for player hand
var deck_angle = 0
var deck_pos
var deck_scale := 1.0

##shader stuff
@onready
var sprite_ref = self

var dissolving = false
var dissolve_value = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# factory constructor, to override
func set_up(cardinstance_data : CardInstanceData, cardimg_bg : Texture2D) -> void:
	get_node("CardImage").texture = cardimg_bg
	get_node("EntityImage").texture = cardinstance_data.get_data().card_sprite
	get_node("Texts/CardName").text = cardinstance_data.get_data().display_name
	self.cardinstance_dataid = cardinstance_data.get_id()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dissolving:
		get_node("Texts").visible = false
		if dissolve_value > 0:
			sprite_ref.material.set_shader_parameter("DissolveValue", dissolve_value)
			dissolve_value -= delta * 1.6
		else:
			sprite_ref.visible = false
			queue_free()
	pass

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

######################################################################

func _on_area_2d_mouse_entered() -> void:
	emit_signal("mouse_on", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("mouse_off", self)

func card_flip_to_entity() -> void:
	get_node("FlipAnimation").play("card_flip_to_entity")

func entity_flip_to_card() -> void:
	get_node("FlipAnimation").play("entity_flip_to_card")

func get_data_instance_id() -> String:
	return cardinstance_dataid
