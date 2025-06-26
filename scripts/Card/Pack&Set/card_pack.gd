extends Node2D
class_name CardPack

@export var pack_sets : Array[Array]##array of sets

var is_cardsets_interactable := false

var pack_arr = []
var choices := 1

var pack_index : int
var pack_id : int

##logic stuff
var card_sets = preload("res://scenes/Card/card_set.tscn")
static var card_pack = preload("res://scenes/Card/card_pack.tscn")


##shader stuff
@onready
var sprite_ref = self
var dissolving = false
var dissolve_value = 1

func _ready() -> void:
	get_node("AnimationPlayer").play("fall animation")

func set_cardset_interactable() -> void:
	is_cardsets_interactable = true

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

func open_pack() -> void:
	self.get_node("Area2D/CollisionShape2D").disabled = true
	var pack_size = pack_sets.size()
	var set_angle = 2 * PI / pack_size
	var set_radius_from_pack = 100
	for i in range(pack_size):
		# Creation of cardsets
		var new_set = card_sets.instantiate()
		new_set.set_up(pack_sets[i], i, pack_id)
		new_set.global_position = Vector2(200 * cos(set_angle* i), 200 * sin(set_angle* i))
		pack_arr.insert(pack_arr.size(), new_set)
		add_child(new_set)
	
	Signalbus.emit_signal("choose_pack", pack_index)

func select_option(set_option : CardSet) -> void:
	if !is_cardsets_interactable:
		return
	
	if set_option in pack_arr:
		set_option.shift_to_hand()
		
		# Remove choices from the card pack options
		pack_arr.erase(set_option)
		choices -= 1
		if choices == 0:
			destroy_pack()

func destroy_pack() -> void:
	for cardset in pack_arr:
		cardset.get_node("Area2D/CollisionShape2D").disabled = true
		cardset.dissolve_set()

	dissolving = true

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
