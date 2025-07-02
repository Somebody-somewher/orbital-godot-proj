extends Node2D
class_name CardPack

@export var pack_sets : Array[Array]##array of sets

var is_cardsets_interactable := false

@export var prepack_sets : Array[CardSetData]

var pack_arr = []
var choices := 1

var is_chosen : bool
var are_sets_choosable : bool

var pack_index : int
var pack_id : int
var remove_self : Callable

##logic stuff
var card_sets = preload("res://scenes/Card/card_set.tscn")
static var card_pack = preload("res://scenes/Card/card_pack.tscn")

@onready var buttons: Control = $Buttons
@onready var input_manager: InputManager = $"../../InputManager"
@onready var cardpack_sprite : Sprite2D = $Sprite2D

##shader stuff
@onready
var sprite_ref = self
var dissolving = false
var dissolve_value = 1

func _ready() -> void:
	buttons.visible = false
	get_node("AnimationPlayer").play("fall animation")

func set_cardset_interactable(remove_self : Callable) -> void:
	is_cardsets_interactable = true
	self.remove_self = remove_self

# factory constructor
#static func new_pack(setdata : Array[CardSetData]) -> CardPack:
	#var return_pack : CardPack = card_pack.instantiate()
	#return_pack.pack_sets = setdata
	#return_pack.z_index = 50
	#return return_pack

static func new_pack(setdata : Array, pack_index : int, pack_id : int) -> CardPack:
	var return_pack : CardPack = card_pack.instantiate()
	return_pack.pack_sets.assign(setdata)
	return_pack.z_index = 50
	return_pack.pack_index = pack_index
	return_pack.pack_id = pack_id
	return return_pack

func _process(delta: float) -> void:
	if dissolving:
		if dissolve_value > 0:
			sprite_ref.material.set_shader_parameter("DissolveValue", dissolve_value)
			dissolve_value -= delta * 1.6
		else:
			sprite_ref.visible = false
			queue_free()

func select_pack() -> void:
	buttons.visible = true

func _on_check_pressed() -> void:
	Signalbus.emit_signal("choose_pack", pack_index)
	buttons.visible = false

func _on_cross_pressed() -> void:
	buttons.visible = false
	input_manager.curr_mask = 0xFFFFFFFF

func choose_or_open() -> void:
	if is_chosen:
		if are_sets_choosable:
			open_pack()
	else:
		select_pack()
	
func open_pack() -> void:
	self.get_node("Area2D/CollisionShape2D").disabled = true
	var pack_size = pack_sets.size()
	
	if pack_size == 0:
		destroy_pack()
		return
	
	var set_angle = 2 * PI / pack_size
	var set_radius_from_pack = 100
	for i in range(pack_size):
		# Creation of cardsets
		var new_set = card_sets.instantiate()
		new_set.set_up(pack_sets[i], i, pack_id)
		new_set.global_position = Vector2(200 * cos(set_angle* i), 200 * sin(set_angle* i))
		pack_arr.insert(pack_arr.size(), new_set)
		add_child(new_set)
	
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
	for cardset in pack_arr:
		cardset.get_node("Area2D/CollisionShape2D").disabled = true
		cardset.dissolve_set()

	dissolving = true

func pack_chosen_update(colour_to_update : Color) -> void:
	# Show indication pack was chosen
	is_chosen = true
	pass

func _on_area_2d_mouse_entered() -> void:
	highlight_pack(true)
	
func _on_area_2d_mouse_exited() -> void:
	highlight_pack(false)

func highlight_pack(on : bool) -> void:
	var tween = get_tree().create_tween()
	if on:
		tween.parallel().tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	else:
		tween.parallel().tween_property(self, "scale", Vector2(1, 1), 0.1)
		
func get_id() -> int:
	return pack_id

func make_sets_choosable() -> void:
	are_sets_choosable = true
