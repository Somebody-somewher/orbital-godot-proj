class_name  PlayerInfo
extends Object

var _pid : int
var _pName : String

func _init(id : int, pName : String) -> void:
	_pid = id
	_pName = pName 

func getPlayerId():
	return _pid

func getPlayerName():
	return _pName
