extends Control

@export var ip : String = "127.0.0.1"
@export var port : int = 40333
@export var gameScene : PackedScene 
#var multiplayer_peer = ENetMultiplayerPeer.new()


# Resources
# Following this tutorial mainly: 
# https://www.youtube.com/watch?v=e0JLO_5UgQo
# https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html

# Peer basically means Computer
# To debug -> Debug -> Customize Run Instances -> Enable Multiple Instances

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
		print("cannot host. Error: " + str(error))
		return error
	multiplayer.multiplayer_peer = peer
	_register_player($NameInput.text, multiplayer.get_unique_id())
	
func _connect_client(addr = ""):
	var peer = ENetMultiplayerPeer.new()
	
	if $IPInput.text.is_empty():
		addr = ip
	else:
		addr = $IPInput.text
	var error = peer.create_client(addr, port)
	if (error != OK):
		print("cannot host: " + error)
		return error
		
	multiplayer.multiplayer_peer = peer
	_register_player($NameInput.text, multiplayer.get_unique_id())


func _leave_lobby():
	multiplayer.multiplayer_peer = null
	

# This signal is emitted with the newly connected peer's ID on each other peer 
# (inclusive of the server, which is also a peer) 
# and on the new peer multiple times, once with each other peer's ID.
func _on_peer_connected(id : int)  -> void:
	# Note that the server's peer id will always be 1
	print("Player Connected " + str(id))
	
	# When a peer connects, each already-connected peer sends their info to the new peer
	# Likewise each connected peer receives only the new peer's data
	_register_player.rpc_id(id, $NameInput.text)

@rpc("any_peer", "reliable")
func _register_player(newPlayerName : String, newPlayerId : int = multiplayer.get_remote_sender_id()):
	print(newPlayerName)
	# PlayerManager belongs to the current player is not universal
	PlayerManager.addPlayer(PlayerInfo.generateUUID(newPlayerName), newPlayerId, newPlayerName)

# This signal is emitted on every remaining peer when one disconnects.
func _on_peer_disconnected(id : int)  -> void:
	PlayerManager.erasePlayer(id)
	print("Player Disconnected " + str(id))

# For sending info frm client -> server
# Called only from clients
func _on_connected_to_server()  -> void:
	print($NameInput.text + " has connected to the server! :D")

func _on_connection_failed() -> void:
	print("Connection Failed :<")
	_leave_lobby()

func _on_server_disconnected():
	print("Server ded X.X")
	PlayerManager.clearPlayers()
	_leave_lobby()

func _on_host_button_down() -> void:
	_create_server()
	print($NameInput.text + " is waiting for Players! .o.")

func _on_join_button_down() -> void:
	_connect_client(ip)
	pass # Replace with function body.

func _on_start_button_down() -> void:
	startGame.rpc()
	pass # Replace with function body.

#TODO: Change this
@rpc("any_peer", "call_local")
func startGame():
	NetworkManager.set_up()
	var scene = gameScene.instantiate()
	get_tree().root.add_child(scene)
	self.hide()
