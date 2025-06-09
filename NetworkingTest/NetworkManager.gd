extends Control

@export var ip : String = "127.0.0.1"
@export var port : int = 8910
#var multiplayer_peer = ENetMultiplayerPeer.new()


# Resources
# Following this tutorial mainly: 
# https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html


# Peer basically means Computer

# To terminate networking: multiplayer.multiplayer_peer = null

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _create_server():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 2)
	if (error != OK):
		print("cannot host: " + error)
		return error
	multiplayer.multiplayer_peer = peer
	
func _connect_client(address = ""):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, port)
	if (error != OK):
		print("cannot host: " + error)
		return error
		
	multiplayer.multiplayer_peer = peer

func _leave_lobby():
	multiplayer.multiplayer_peer = null

# This signal is emitted with the newly connected peer's ID on each other peer 
# (inclusive of the server, which is also a peer) 
# and on the new peer multiple times, once with each other peer's ID.
func _on_peer_connected(id : int)  -> void:
	# Note that the server's peer id will always be 1
	print("Player Connected " + str(id))

# This signal is emitted on every remaining peer when one disconnects.
func _on_peer_disconnected(id : int)  -> void:
	print("Player Disconnected " + str(id))

# For sending info frm client -> server
# Called only from clients
func _on_connected_to_server()  -> void:
	print("I've connected to the server! :D")

func _on_connection_failed() -> void:
	print("Connection Failed :<")
	_leave_lobby()
	pass # Replace with function body.

func _on_server_disconnected():
	print("Server ded X.X")
	_leave_lobby()


func _on_host_button_down() -> void:
	_create_server()
	print("Waiting for Players! .o.")

func _on_join_button_down() -> void:
	_connect_client(ip)
	pass # Replace with function body.

func _on_start_button_down() -> void:
	pass # Replace with function body.
