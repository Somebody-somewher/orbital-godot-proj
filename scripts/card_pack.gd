extends Node2D

var pack_sets = ["Big Dummy Set", "Dummy Set", "Cow Set", "Cute Dummy Set"] ##array of sets
var pack_arr = []
var choices = 1 ##how many selections of the options

##logic stuff
@onready
var player_hand = $"../PlayerHand"
var card_sets = preload("res://scenes/card_set.tscn")
var card_ref = preload("res://scenes/Card.tscn")

##shader stuff
@onready
var sprite_ref = $Sprite2D
var dissolving = false
var dissolve_value = 1

##database stuff
@onready
var database_ref = preload("res://scripts/card_database.gd")

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if dissolving:
		if dissolve_value > 0:
			sprite_ref.material.set_shader_parameter("DissolveValue", dissolve_value)
			dissolve_value -= delta * 1.6
		else:
			sprite_ref.visible = false
			dissolving = false
			free()

func open_pack():
	self.get_node("Area2D/CollisionShape2D").disabled = true
	for i in range(pack_sets.size()):
		var new_set = card_sets.instantiate()
		var set_name = pack_sets[i]
		new_set.card_arr = database_ref.SETS[set_name]
		new_set.position = Vector2(i * 250 + 400, 300) - self.position
		pack_arr.insert(pack_arr.size(), new_set)
		add_child(new_set)
	pass

func select_option(set_option):
	if set_option in pack_arr:
		set_option.shift_to_hand()
		pack_arr.erase(set_option)
		choices -= 1
		if choices == 0:
			destroy_pack()
	pass

func destroy_pack():
	dissolving = true
	for sets in pack_arr:
		for unchosen_card in sets.card_set:
			unchosen_card.dissolving = true

func _on_area_2d_mouse_entered() -> void:
	highlight_pack(true)
	
func _on_area_2d_mouse_exited() -> void:
		highlight_pack(false)

func highlight_pack(on):
	var tween = get_tree().create_tween()
	if on:
		tween.parallel().tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	else:
		tween.parallel().tween_property(self, "scale", Vector2(1, 1), 0.1)
