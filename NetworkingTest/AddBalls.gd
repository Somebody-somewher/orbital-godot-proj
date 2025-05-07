extends Node2D
@export var ballPath : String = "res://NetworkingTest/MeowMeow.tscn" 

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("leftMouseClick") && multiplayer.get_unique_id() == name.to_int():
		print("TEST")
		createNewBall.rpc(get_global_mouse_position())
			
@rpc("any_peer", "call_local")
func createNewBall(mousePos: Vector2) -> void:
	var newBall = load(ballPath).instantiate()
	newBall.set_position(mousePos)
	add_child(newBall)
