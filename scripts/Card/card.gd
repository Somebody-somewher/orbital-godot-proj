extends Node2D
class_name Card

#for constructor
static var card_scene: PackedScene = load("res://scenes/Card/Card.tscn")

signal mouse_on
signal mouse_off

#animation vars for player hand
var deck_angle = 0
var deck_pos
var in_tile = false

##shader stuff
@onready
var sprite_ref = $CardImage
var dissolving = false
var dissolve_value = 1

#TODO: Change this in CardManager or Pack or wherever you need it
var building : Building

# name to find references in database
var id_name : String = "cute_dummy"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().root.get_node("GameManager/CardManager").connect_card_signals(self) 

# factory constructor
static func new_card(card_name : String) -> Card:
	var return_card : Card = card_scene.instantiate()
	var card_image_path = str("res://sprites/card_sprites/"+ card_name + "_card.png")
	var entity_image_path = str("res://sprites/entity_sprites/"+ card_name + ".png")
	return_card.get_node("CardImage").texture = load(card_image_path)
	return_card.get_node("EntityImage").texture = load(entity_image_path)
	return_card.get_node("GhostBuildingImage").texture = load(entity_image_path)
	return_card.id_name = card_name
	return return_card

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dissolving:
		if dissolve_value > 0:
			sprite_ref.material.set_shader_parameter("DissolveValue", dissolve_value)
			dissolve_value -= delta * 1.6
		else:
			sprite_ref.visible = false
			free()
	pass

# creates building that will be passed when placed on board
# called when added to player hand
func initialize_building() -> void:
	building = Building.new_building(id_name)
	#add_child(building)
	building.visible = true
	building.get_node("Area2D/CollisionShape2D").disabled = true

# fully replace card with building, then free self instance
func swap_to_building(new_parent, scale_by: Vector2) -> void:
	#building.reparent(new_parent)
	self.get_node("Area2D/CollisionShape2D").disabled = true
	building.scale = scale_by
	building.visible = true
	building.get_node("Area2D/CollisionShape2D").disabled = false
	queue_free()

func _on_area_2d_mouse_entered() -> void:
	emit_signal("mouse_on", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("mouse_off", self)

func card_flip_to_entity() -> void:
	get_node("FlipAnimation").play("card_flip_to_entity")

func entity_flip_to_card() -> void:
	get_node("FlipAnimation").play("entity_flip_to_card")
