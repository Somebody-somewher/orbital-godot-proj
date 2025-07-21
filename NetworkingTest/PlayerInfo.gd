class_name  PlayerInfo
extends Object

var pid : int
var pName : String
var pUuid : String
var pColour : Color


func _init(uuid : String, id : int, name : String, colour : Color) -> void:
	pUuid = uuid
	pid = id
	pName = name
	pColour = colour
 
func getPlayerId() -> int:
	return pid

func changePlayerId(new_pid : int) -> void:
	pid = new_pid

func getPlayerName() -> String:
	return pName

func getPlayerUUID() -> String:
	return pUuid

func getColor() -> Color:
	return pColour

static func generateUUID(pName : String) -> String:
	var hardware_id := OS.get_unique_id()
	return (pName + "|" + hardware_id).sha256_text()
