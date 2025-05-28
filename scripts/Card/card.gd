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
var deck_pos

##shader stuff
@onready
var sprite_ref = self
var dissolving = false
var dissolve_value = 1

# name to find references in database
var id_name : String = "cute_dummy"

static var database_ref = preload("res://scripts/Card/card_database.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func connect_to_card_manager(card_man : CardManager) -> void:
	card_man.connect_card_signals(self) 

# factory constructor
static func new_card(card_name : String) -> Card:
	var return_card : Card = card_scene.instantiate()
	var card_image_path = str("res://assets/card_sprites/blank_card.png")
	var entity_image_path = str("res://assets/entity_sprites/"+ card_name + ".png")
	return_card.get_node("CardImage").texture = load(card_image_path)
	return_card.get_node("EntityImage").texture = load(entity_image_path)
	return_card.get_node("GhostImage").texture = load(entity_image_path)
	return_card.get_node("Texts/CardName").text = database_ref.get_card_name_by_id(card_name)
	return_card.id_name = card_name
	return return_card

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dissolving:
		get_node("GhostImage").visible = false
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
