extends Node2D

@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
var start_pos : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = start_pos
	cpu_particles_2d.emitting = true
	

func _on_cpu_particles_2d_finished() -> void:
	queue_free()
