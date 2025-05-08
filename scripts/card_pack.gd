extends Node2D

var pack_sets = ["dummy", "dummy", "dummy"] ##array of sets
var pack_arr = []
var choices = 1 ##how many selections of the options

@onready
var player_hand = $"../PlayerHand"
var card_sets = preload("res://scenes/card_set.tscn")
var card_ref = preload("res://scenes/Card.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func open_pack():
	self.get_node("Area2D/CollisionShape2D").disabled = true
	for i in range(pack_sets.size()):
		var card_set = card_sets.instantiate()
		card_set.position = Vector2(i * 200 + 100, 100)
		pack_arr.insert(pack_arr.size(), card_set)
		add_child(card_set)
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
	pass
