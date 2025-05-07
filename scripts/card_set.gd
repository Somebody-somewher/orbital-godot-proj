extends Node2D

var card_arr = [] ##2d array of [card, number]

signal mouse_on
signal mouse_off

@onready
var card_manager = $"../.."

var card = preload("res://scenes/Card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().get_parent().connect_card_signals(self)
