extends Object
class_name ClientNetworkManager

var _nodes_ready : Dictionary[String, bool] = {}

var _client_ready : Callable
var count : int = 0

func _init(nodes_ready : Dictionary[String, bool], client_ready : Callable) -> void:
	_nodes_ready = nodes_ready
	_client_ready = client_ready

func reset_node_status() -> void:
	for key in _nodes_ready.keys():
		_nodes_ready[key] = false

func mark_ready(node : Node) -> void:
	if _nodes_ready[node.name] == false:
		count += 1
		_nodes_ready[node.name] = true
	
	if count == len(_nodes_ready):
		_client_ready.rpc_id(1)
