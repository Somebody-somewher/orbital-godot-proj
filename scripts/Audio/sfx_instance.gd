extends AudioStreamPlayer
class_name SFXInstance

var from_position := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play(from_position)


func _on_finished() -> void:
	queue_free()
