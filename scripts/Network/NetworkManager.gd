extends Node

signal all_clients_ready

var client_net : ClientNetworkManager
var server_net : ServerNetworkManager

var is_server_client : bool = true

@export var check_lobby : String

# These components have some game logic functionality
# As such the server must have authoritative control over them
# However, in order for the server to supply data the components
# must first to be ready to receive data 
@export var components : Dictionary[String, bool]

func set_up() -> void:
	print("NETWORK ", multiplayer.get_unique_id())
	if multiplayer.get_unique_id() == 1:
		server_net = ServerNetworkManager.new()
		if is_server_client:
			client_net = ClientNetworkManager.new(components, client_ready_to_server)
	else:
		client_net = ClientNetworkManager.new(components, client_ready_to_server)

func mark_client_ready(node : Node) -> void:
	if client_net != null:
		client_net.mark_ready(node)
	else:
		printerr("Non-client trying to mark ready")

@rpc("any_peer","call_local")
func client_ready_to_server() -> void:
	server_net.mark_player_as_ready(multiplayer.get_remote_sender_id())
	
func is_client() -> bool:
	return multiplayer.get_unique_id() != 1 or is_server_client

func _ready() -> void:
	## TODO: Need a better system than this
	if "HostNetworking" != get_tree().current_scene.name:
		set_up()
	pass

func _process(delta: float) -> void:
	pass
