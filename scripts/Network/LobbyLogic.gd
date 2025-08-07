extends Node
class_name LobbyLogic

# Ideally we should separate these two components
var ip_addr_field : TextEdit
var port_field : TextEdit 
var j_name_field : TextEdit
var player_list_label : Label

var h_name_field : TextEdit
var h_player_list_label : Label

var _ip : String = "127.0.0.1"
var _port : int = 8910
var curr_status : String = ""
var player_list_string : String = ""

var ip_check = RegEx.new()

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

	ip_check.compile(r"^(\d{1,3}\.){3}\d{1,3}$")

func set_up_host(h_name_field : TextEdit, h_player_list_label : Label) -> void:
	self.h_name_field = h_name_field
	self.h_player_list_label = h_player_list_label
	h_player_list_label.text = ""

func set_up_client(ip_addr_field : TextEdit, port_field : TextEdit, j_name_field : TextEdit, player_list_label : Label) -> void:
	self.ip_addr_field = ip_addr_field
	self.port_field = port_field
	self.j_name_field = j_name_field
	self.player_list_label = player_list_label
	player_list_label.text = ""

func _create_server():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(_port, 4)
	if (error != OK):
		curr_status = "Cannot host. Error: " + str(error) 
		return error
	multiplayer.multiplayer_peer = peer
	PlayerManager.declare_multiplayer()	
	_register_player(h_name_field.text, PlayerInfo.generateUUID(h_name_field.text), multiplayer.get_unique_id())

	
func _connect_client(addr = "", port = ""):	
	var port_num : int
	
	if SceneManager.curr_scene == "menu" and multiplayer.multiplayer_peer is ENetMultiplayerPeer:
		return
	
	if addr == "":
		addr = _ip
	
	if !ip_check.search(addr):
		curr_status = "INVALID IP"
		printerr(curr_status)
		return
	
	if port == "":
		port = _port
	else:
		if typeof(port) != TYPE_INT:
			return
	
	print(addr, " ", port)
	
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(addr, int(port))
	if (error != OK):
		curr_status = "cannot host: " + str(error)
		return error
		
	multiplayer.multiplayer_peer = peer
	PlayerManager.declare_multiplayer()	
	_register_player(j_name_field.text, PlayerInfo.generateUUID(j_name_field.text), multiplayer.get_unique_id())


func _leave_lobby():
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	
#func menu_leave_lobby():
	#PlayerManager.erasePlayer.rpc(multiplayer.get_unique_id())
	#
	#list_all_players.rpc()
	#await get_tree().create_timer(0.5).timeout 
	#multiplayer.multiplayer_peer = null
	#
	#if player_list_label:
		#player_list_label.text = ""
	#
	#if h_player_list_label:
		#h_player_list_label.text = ""	

# This signal is emitted with the newly connected peer's ID on each other peer 
# (inclusive of the server, which is also a peer) 
# and on the new peer multiple times, once with each other peer's ID.
func _on_peer_connected(id : int)  -> void:
	# Note that the server's peer id will always be 1
	curr_status = "Player Connected " + str(id)
	print(curr_status)
	var player_name : String = PlayerManager.getCurrentPlayerName()
	
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
	#PlayerManager.erasePlayer(id)
	curr_status = "Player Disconnected " + str(id)
	
	if SceneManager.curr_scene == "menu":
		PlayerManager.erasePlayer(id)
		list_all_players()
		
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
	#PlayerManager.clearPlayers()
	
	if SceneManager.curr_scene == "menu":
		clear_player_list()
	#_leave_lobby()
	
	SceneManager.back_to_menu()
	reset_lobby()

func on_host_pressed() -> void:
	_create_server()
	curr_status = "Awaiting players!"
	print(h_name_field.text + " is waiting for Players! .o.")
	if get_tree().root.get_node("MainMenu/PlayerHand").hand_arr.size() < 2:
		get_tree().root.get_node("MainMenu/MenuLogic").spawn_card("start_game")
	pass # Replace with function body.

func on_join_pressed() -> void:
	_connect_client(ip_addr_field.text, port_field.text)
	pass # Replace with function body.

@rpc("any_peer", "call_local")
func list_all_players() -> void:
	player_list_string = ""
	PlayerManager.forEachPlayer(_list_player)
	
	player_list_label.text = player_list_string
	h_player_list_label.text = player_list_string

func _list_player(pi : PlayerInfo) -> void:
	player_list_string = player_list_string + pi.getPlayerName() + "\n"

#@rpc("any_peer", "call_local")
func clear_player_list() -> void:
	if player_list_label:
		player_list_label.text = ""
	
	if h_player_list_label:
		h_player_list_label.text = ""

func reset_lobby() -> void:	
	
	clear_player_list()
	_leave_lobby()
	
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new() #dummy_peer
	PlayerManager.reset()
