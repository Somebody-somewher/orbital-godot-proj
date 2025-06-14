class_name  PlayerInfo
extends Object

var pid : int
var pName : String

# Board data
var _boards_interactable : Array[bool] = []

func _init(id : int, pName : String) -> void:
	pid = id
	pName = pName 
 

func getPlayerId():
	return pid

func getPlayerName():
	return pName
