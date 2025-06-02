extends Node2D
@export var ballPath : String = "res://NetworkingTest/MeowMeow.tscn" 

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("leftMouseClick") && multiplayer.get_unique_id() == name.to_int():
		print("TEST")
		createAuthorityBall.rpc(get_global_mouse_position())

# All players can spawn balls, balls synced and seen on all	
@rpc("any_peer", "call_local")
func createNewBall(mousePos: Vector2) -> void:
	var newBall = load(ballPath).instantiate()
	newBall.set_position(mousePos)
	add_child(newBall)
 
# Everyone can do this action and see their own ball spawn, but only server's balls are synced and seen by all
@rpc("authority", "call_local")
func createMeBall(mousePos: Vector2) -> void:
	var newBall = load(ballPath).instantiate()
	newBall.set_position(mousePos)
	add_child(newBall)

# Only server can initiate this action (spawns ball, but not seen), balls synced and seen on other players except server
@rpc("authority", "call_remote")
func createAuthorityBall(mousePos: Vector2) -> void:
	var newBall = load(ballPath).instantiate()
	newBall.set_position(mousePos)
	add_child(newBall)

# Everybody can spawn balls, but balls are only seen on the other's 
@rpc("any_peer", "call_remote")
func createTheyBall(mousePos: Vector2) -> void:
	var newBall = load(ballPath).instantiate()
	newBall.set_position(mousePos)
	add_child(newBall)
