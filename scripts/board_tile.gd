extends Node2D

class_name BoardTile

var tile_built = false

signal mouse_on_range
signal mouse_off_range


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().root.get_child(0).get_node("CardManager").connect_tile_signals(self) 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_card_flip_range_mouse_entered() -> void:
	emit_signal("mouse_on_range", self)

func _on_card_flip_range_mouse_exited() -> void:
	emit_signal("mouse_off_range", self)
