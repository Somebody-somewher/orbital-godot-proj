class_name  PlayerInfo
extends Object

var pid : int
var pName : String
var uuid : String
var colour : Color
# Board data
var _boards_interactable : Array[bool] = []

func _init(uuid : String, id : int, pName : String, colour : Color) -> void:
	self.uuid = uuid
	self.pid = id
	self.pName = pName
	self.colour = colour
 
func getPlayerId() -> int:
	return pid

func changePlayerId(new_pid : int) -> void:
	pid = new_pid

func getPlayerName() -> String:
	return pName

func getPlayerUUID() -> String:
	return uuid

func getColor() -> Color:
	return colour

static func generateUUID(pName : String) -> String:
	var hardware_id := OS.get_unique_id()
	return (pName + "|" + hardware_id).sha256_text()
