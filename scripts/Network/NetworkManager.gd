extends Node

signal all_clients_ready

var client_net : ClientNetworkManager
var server_net : ServerNetworkManager

var is_server_client : bool = true

# A stupid check to see if whether we are starting from the multiplayer lobby
# If we aren't then the default is that each debug instance is a separate game
@export var check_lobby : String

# If sync is finished, we can start normal gameplay-interactivity like camera
var is_sync_fin : bool = false

# These components have some game logic functionality
# As such the server must have authoritative control over them
# However, in order for the server to supply data the components
# must first to be ready to receive data 
@export var client_components : Dictionary[String, bool]
@export var server_components : Dictionary[String, bool]

func set_up() -> void:
	if multiplayer.get_unique_id() == 1:
		server_net = ServerNetworkManager.new(server_components)
		if is_server_client:
			client_net = ClientNetworkManager.new(client_components, client_ready_to_server)
	else:
		client_net = ClientNetworkManager.new(client_components, client_ready_to_server)

@rpc("any_peer","call_local")
func mark_client_ready(node_name : String) -> void:
	if client_net != null:
		client_net.mark_ready(node_name)
	else:
		printerr("Non-client trying to mark ready")

@rpc("any_peer","call_local")
func client_ready_to_server() -> void:
	server_net.mark_player_as_ready(multiplayer.get_remote_sender_id())
	
func is_client() -> bool:
	return multiplayer.get_unique_id() != 1 or is_server_client

@rpc("any_peer", "call_local")
func toggle_sync_finish() -> void:
	is_sync_fin = !is_sync_fin

@rpc("any_peer", "call_local")
func reset_networking() -> void:
	is_sync_fin = false
	if server_net != null:
		server_net.is_syncing = false

func _ready() -> void:
	## TODO: Need a better system than this
	if "HostNetworking" != get_tree().current_scene.name:
		set_up()
	pass

func _process(delta: float) -> void:
	pass
