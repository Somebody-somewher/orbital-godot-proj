extends Node2D

var pack_sets = [] ##array of sets
var choices = 1 ##how many selections of the options

@onready
var player_hand = $"../../PlayerHand"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func open_pack():
	pass

func select_option(option):
	pass
