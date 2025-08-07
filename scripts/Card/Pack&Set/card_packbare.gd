extends Node2D
class_name CardPackBare

#@export var pack_sets : Array[Array]##array of sets
@export var pack_sets : Dictionary[String, Array]
@onready var outline : Sprite2D = $Outline
@export var prepack_sets : Array[CardSetData]

var pack_arr = []
var choices := 1

var is_chosen : bool
var are_sets_choosable : bool

var pack_id : int
var remove_self : Callable

##logic stuff
static var card_pack = preload("res://scenes/Card/card_pack.tscn")

@onready var cardpack_sprite : Sprite2D = $Sprite2D

##shader stuff
@onready
var sprite_ref = self
var dissolving = false
var dissolve_value = 1
var enable_3d = false

func _ready() -> void:
	get_node("AnimationPlayer").play("fall animation")
	sprite_ref.material.set_shader_parameter("dissolve_value", dissolve_value)

# func new_pack(setdata : Dictionary[String, Array], pack_id : int) -> CardPack:
static func new_pack(setdata : Dictionary, pack_id : int) -> CardPack:
	var return_pack : CardPack = card_pack.instantiate()
	return_pack.pack_sets.assign(setdata)
	return_pack.z_index = 50
	return_pack.pack_id = pack_id
	return return_pack

func _process(delta: float) -> void:
	if dissolving:
		if dissolve_value > 0:
			dissolve_value = dissolve_value - delta * 1.6
			sprite_ref.material.set_shader_parameter("dissolve_value", dissolve_value)
		else:
			sprite_ref.self_modulate = Color(1, 1, 1, 0)
	if enable_3d:
		self.material.set_shader_parameter("max_tilt",0.5)
		self.material.set_shader_parameter("mouse_position",get_global_mouse_position())
		self.material.set_shader_parameter("sprite_position",global_position)
	else:
		self.material.set_shader_parameter("max_tilt",0)

func choose_or_open()-> bool:
	open_pack()
	return false

func open_pack() -> void:
	pass

func destroy_pack() -> void:
	await get_tree().create_timer(1).timeout
	queue_free()

func _on_area_2d_mouse_entered() -> void:
	highlight_pack(true)
	
func _on_area_2d_mouse_exited() -> void:
	highlight_pack(false)

func set_outline_color(colour : Color) -> void:
	sprite_ref.material.set_shader_parameter("outline_color", colour)

func outline_pack(on : bool) -> void:
	outline.visible = on

func highlight_pack(on : bool) -> void:
	var tween = get_tree().create_tween()
	enable_3d = on
	if on:
		tween.parallel().tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	else:
		tween.parallel().tween_property(self, "scale", Vector2(1, 1), 0.1)
		
func get_id() -> int:
	return pack_id
