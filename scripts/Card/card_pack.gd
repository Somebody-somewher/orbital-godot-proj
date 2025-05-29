extends Node2D
class_name CardPack

var pack_sets = ["Big Cow Set", "Alcohol", "Worship", "Farm"] ##array of sets
var pack_arr = []
var choices = 1 ##how many selections of the options

##logic stuff
var card_sets = preload("res://scenes/Card/card_set.tscn")
var card_ref = preload("res://scenes/Card/Card.tscn")

##shader stuff
@onready
var sprite_ref = self
var dissolving = false
var dissolve_value = 1

##database stuff
@onready
var database_ref = preload("res://scripts/Card/card_database.gd")

func _ready() -> void:
	get_node("AnimationPlayer").play("fall animation")

#func process_click(node : Node2D, sig : String):
	#if (sig == "cardpack_clicked" && node == self):
		#open_pack()
	#elif (sig == "cardset_clicked" && node.get_parent() == self):
		#select_option(node)

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
	for i in range(pack_sets.size()):
		var new_set = card_sets.instantiate()
		var set_id_name = pack_sets[i]
		new_set.card_arr = database_ref.get_set_cards_by_set_id(set_id_name)
		new_set.global_position = Vector2(i * 250 + 400, 300) - self.position
		pack_arr.insert(pack_arr.size(), new_set)
		add_child(new_set)

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
