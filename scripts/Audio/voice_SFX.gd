extends AudioStreamPlayer
class_name VoiceSFX

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pitch_scale = randf_range(.9, 1.1)
	play()


func _on_finished() -> void:
	queue_free()
