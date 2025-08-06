extends Node2D
class_name CardPack

#@export var pack_sets : Array[Array]##array of sets
@export var pack_sets : Dictionary[String, Array]

@onready var outline : Sprite2D = $Outline
var is_cardsets_interactable := false

@export var prepack_sets : Array[CardSetData]

var pack_arr = []
var choices := 1

var is_chosen : bool
var _owner_uuid : String
var are_sets_choosable : bool

var pack_id : int
var remove_self : Callable

##logic stuff
var card_sets = preload("res://scenes/Card/card_set.tscn")
static var card_pack = preload("res://scenes/Card/card_pack.tscn")

@onready var buttons: Control = $Buttons
@onready var cardpack_sprite : Sprite2D = $Sprite2D

##shader stuff
@onready
var sprite_ref = self
var dissolving = false
var dissolve_value = 1
var enable_3d = false

func _ready() -> void:
	global_position = Vector2(550, 450)
	buttons.visible = false
	get_node("AnimationPlayer").play("fall animation")

func set_cardset_interactable(remove_self : Callable) -> void:
	is_cardsets_interactable = true
	self.remove_self = remove_self

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
	Signalbus.emit_signal("choose_pack", pack_id)
	buttons.visible = false

func _on_cross_pressed() -> void:
	buttons.visible = false
	Signalbus.emit_signal("change_input_mask", 0xFFFFFFFF)

# Returns boolean based on whether we needa pause every other input
func choose_or_open() -> bool:
	if is_chosen:
		if are_sets_choosable:
			open_pack()
			return true
	else:
		select_pack()
	return false

func pack_chosen_update(owner_uuid : String, colour_to_update : Color) -> void:
	# Show indication pack was chosen
	_owner_uuid = owner_uuid
	set_outline_color(colour_to_update)
	outline_pack(true)
	is_chosen = true
	pass

func open_pack() -> void:
	self.get_node("Area2D/CollisionShape2D").disabled = true
	get_node("AnimationPlayer").play("shake")
	var pack_size = pack_sets.size()
	
	if pack_size == 0:
		destroy_pack()
		return
	
	var set_angle = 2 * PI / pack_size
	var set_radius_from_pack = 100
	
	var keys = pack_sets.keys()
	var cards_in_sets = pack_sets.values()
	for i in range(len(pack_sets)):
		# Creation of cardsets
		var new_set = card_sets.instantiate()
		new_set.set_up(cards_in_sets[i], keys[i], pack_id)
		new_set.global_position = Vector2(200 * cos(set_angle* i), 200 * sin(set_angle* i))
		pack_arr.insert(pack_arr.size(), new_set)
		add_child(new_set)
	
	dissolving = true

func select_option(set_option : CardSet) -> void:
	if !is_cardsets_interactable:
		return
	
	if set_option in pack_arr:
		set_option.shift_to_hand()
		
		# Remove choices from the card pack options
		pack_arr.erase(set_option)
		choices -= 1
		if choices == 0:
			if !remove_self.is_null():
				remove_self.call(pack_id)
			else:
				destroy_pack()

func destroy_pack() -> void:
	dissolving = true
	for cardset in pack_arr:
		cardset.get_node("Area2D/CollisionShape2D").disabled = true
		cardset.dissolve_set()
	await get_tree().create_timer(1).timeout
	queue_free()

func set_outline_color(colour : Color) -> void:
	sprite_ref.material.set_shader_parameter("outline_color", colour)

func outline_pack(on : bool) -> void:
	outline.visible = on


func _on_area_2d_mouse_entered() -> void:
	highlight_pack(true)
	
func _on_area_2d_mouse_exited() -> void:
	highlight_pack(false)

func highlight_pack(on : bool) -> void:
	var tween = get_tree().create_tween()
	enable_3d = on
	if on:
		tween.parallel().tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	else:
		tween.parallel().tween_property(self, "scale", Vector2(1, 1), 0.1)
		
func get_id() -> int:
	return pack_id

func get_owner_uuid() -> String:
	return _owner_uuid

func make_sets_choosable() -> void:
	are_sets_choosable = true
