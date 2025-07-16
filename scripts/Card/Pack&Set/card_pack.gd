extends Node2D
class_name CardPack

@export var pack_sets : Array[CardSetData]
var pack_arr = []
var choices := 1

##logic stuff
var card_sets = preload("res://scenes/Card/card_set.tscn")
static var card_pack = preload("res://scenes/Card/card_pack.tscn")

@onready var buttons: Control = $Buttons
@onready var input_manager: InputManager = $"../../InputManager"
@onready var outline: Sprite2D = $Outline


##shader stuff
@onready
var sprite_ref = self
var dissolving = false
var dissolve_value = 1
var enable_3d = false

func _ready() -> void:
	outline.visible = false
	buttons.visible = false
	get_node("AnimationPlayer").play("fall animation")
	
# factory constructor
# TODO: pass the placeabale_data as the param instead?
static func new_pack(setdata : Array[CardSetData]) -> CardPack:
	var return_pack : CardPack = card_pack.instantiate()
	return_pack.pack_sets = setdata
	return_pack.z_index = 50
	return return_pack


func _process(delta: float) -> void:
	if dissolving:
		if dissolve_value > 0:
			sprite_ref.material.set_shader_parameter("dissolve_value", dissolve_value)
			dissolve_value -= delta * 1.6
		else:
			sprite_ref.self_modulate = Color(1, 1, 1, 0)
	if enable_3d:
		self.material.set_shader_parameter("max_tilt",0.5)
		self.material.set_shader_parameter("mouse_position",get_global_mouse_position())
		self.material.set_shader_parameter("sprite_position",global_position)
	else:
		self.material.set_shader_parameter("max_tilt",0)

func select_pack() -> void:
	buttons.visible = true

func _on_check_pressed() -> void:
	open_pack()
	buttons.visible = false

func _on_cross_pressed() -> void:
	buttons.visible = false
	input_manager.curr_mask = 0xFFFFFFFF
	

func open_pack() -> void:
	self.get_node("Area2D/CollisionShape2D").disabled = true
	get_node("AnimationPlayer").play("shake")
	var pack_size = pack_sets.size()
	
	if pack_size == 0:
		destroy_pack()
		return
	
	var set_angle = 2 * PI / pack_size
	var set_radius_from_pack = 100
	for i in range(pack_size):
		var new_set = card_sets.instantiate()
		var set_data = pack_sets[i]
		new_set.card_dict = set_data.cards
		new_set.global_position = Vector2(200 * cos(set_angle* i), 200 * sin(set_angle* i))
		pack_arr.insert(pack_arr.size(), new_set)
		add_child(new_set)
	
	dissolving = true

func select_option(set_option : CardSet) -> void:
	if set_option in pack_arr:
		set_option.shift_to_hand()
		pack_arr.erase(set_option)
		choices -= 1
		if choices == 0:
			destroy_pack()

func destroy_pack() -> void:
	for sets in pack_arr:
		sets.get_node("Area2D/CollisionShape2D").disabled = true
		for unchosen_card in sets.card_set:
			unchosen_card.dissolve_card()
	await get_tree().create_timer(1).timeout
	queue_free()

func _on_area_2d_mouse_entered() -> void:
	highlight_pack(true)
	
func _on_area_2d_mouse_exited() -> void:
	highlight_pack(false)

func set_outline_color(r : int, g: int, b: int) -> void:
	sprite_ref.material.set_shader_parameter("outline_color", Color(r,g,b, 1.0))

func outline_pack(on : bool) -> void:
	outline.visible = on

func highlight_pack(on : bool) -> void:
	var tween = get_tree().create_tween()
	enable_3d = on
	if on:
		tween.parallel().tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	else:
		tween.parallel().tween_property(self, "scale", Vector2(1, 1), 0.1)
