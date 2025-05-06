extends Node2D
var ballPath = load("res://NetworkingTest/MeowMeow.tscn")

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("leftMouseClick"):
		print("TEST")
		createNewBall(get_global_mouse_position())
			

func createNewBall(mousePos: Vector2) -> void:
	var newBall = ballPath.instantiate()
	newBall.set_position(mousePos)
	add_child(newBall)
