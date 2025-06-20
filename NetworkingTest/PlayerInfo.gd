class_name  PlayerInfo
extends Object

var pid : int
var pName : String
var uuid : String

# Board data
var _boards_interactable : Array[bool] = []

func _init(uuid : String, id : int, pName : String) -> void:
	self.uuid = uuid
	self.pid = id
	self.pName = pName 
 
func getPlayerId() -> int:
	return pid

func changePlayerId(new_pid : int) -> void:
	pid = new_pid

func getPlayerName() -> String:
	return pName

func getPlayerUUID() -> String:
	return uuid

static func generateUUID(pName : String) -> String:
	var hardware_id := OS.get_unique_id()
	return (pName + "|" + hardware_id).sha256_text()
