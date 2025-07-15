extends Control

@export var ip_addr_field : TextEdit
@export var port_field : TextEdit
@export var j_name_field : TextEdit
@export var player_list_label : Label

@export var h_name_field : TextEdit

@export var h_player_list_label : Label

var _ip : String = "127.0.0.1"
var _port : int = 8910
var curr_status : String = ""
var player_list_string : String = ""

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
	var error = peer.create_server(_port, 4)
	if (error != OK):
		curr_status = "Cannot host. Error: " + str(error) 
		return error
	multiplayer.multiplayer_peer = peer
	_register_player(h_name_field.text, PlayerInfo.generateUUID(h_name_field.text), multiplayer.get_unique_id())

	
func _connect_client(addr = "", port = ""):
	var peer = ENetMultiplayerPeer.new()
	
	# TODO: Please implement error handling? 
	if addr == "":
		addr = _ip
	
	if port == "":
		port = _port
	
	print(addr, " ", port)
	var error = peer.create_client(addr, int(port))
	if (error != OK):
		curr_status = "cannot host: " + str(error)
		return error
		
	multiplayer.multiplayer_peer = peer
	_register_player(j_name_field.text, PlayerInfo.generateUUID(j_name_field.text), multiplayer.get_unique_id())


func _leave_lobby():
	multiplayer.multiplayer_peer = null
	
# This signal is emitted with the newly connected peer's ID on each other peer 
# (inclusive of the server, which is also a peer) 
# and on the new peer multiple times, once with each other peer's ID.
func _on_peer_connected(id : int)  -> void:
	# Note that the server's peer id will always be 1
	curr_status = "Player Connected " + str(id)
	print(curr_status)
	var player_name : String
	# When a peer connects, each already-connected peer sends their info to the new peer
	# Likewise each connected peer receives only the new peer's data
	if id == 1:
		player_name = j_name_field.text
	else:
		player_name = h_name_field.text
	_register_player.rpc(player_name, PlayerInfo.generateUUID(player_name))
	
@rpc("any_peer", "reliable")
func _register_player(newPlayerName : String, player_uuid : String, newPlayerId : int = multiplayer.get_remote_sender_id()):
	# PlayerManager belongs to the current player is not universal
	if !PlayerManager.hasPlayerUUID(player_uuid):
		print("REGISTERING NEW PLAYER ",newPlayerName)

		PlayerManager.addPlayer(player_uuid, newPlayerId, newPlayerName)
		# Lazy implementation but not a big problem
		list_all_players()

# This signal is emitted on every remaining peer when one disconnects.
func _on_peer_disconnected(id : int)  -> void:
	PlayerManager.erasePlayer(id)
	curr_status = "Player Disconnected " + str(id)
	
	print(curr_status)

# For sending info frm client -> server
# Called only from clients
func _on_connected_to_server()  -> void:
	curr_status = j_name_field.text + " has connected to the server! :D"

	print(curr_status)

func _on_connection_failed() -> void:
	print("Connection Failed :<")
	_leave_lobby()

func _on_server_disconnected():
	Signalbus.emit_signal("notif_msg", "The server has died X.X")
	print("Server ded X.X")
	PlayerManager.clearPlayers()
	_leave_lobby()

func _on_host_pressed() -> void:
	_create_server()
	curr_status = "Awaiting players!"
	print(h_name_field.text + " is waiting for Players! .o.")
	pass # Replace with function body.

func _on_join_pressed() -> void:
	_connect_client(ip_addr_field.text, port_field.text)
	pass # Replace with function body.

#func _on_start_button_down() -> void:
	#startGame.rpc()
	#pass # Replace with function body.

#TODO: Change this
#@rpc("any_peer", "call_local")
#func startGame():
	#NetworkManager.set_up()
	#var scene = gameScene.instantiate()
	#get_tree().root.add_child(scene)
	#self.hide()

@rpc("any_peer", "call_local")
func list_all_players() -> void:
	player_list_string = ""
	PlayerManager.forEachPlayer(list_player)
	player_list_label.text = player_list_string
	h_player_list_label.text = player_list_string

func list_player(pi : PlayerInfo) -> void:
	player_list_string = player_list_string + pi.getPlayerName() + "\n"
