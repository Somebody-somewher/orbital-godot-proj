extends Node2D
class_name MenuLogic
# manages behaviour, basically a scene manager

const MENU_HANDS = {
	"main_menu" : ["singleplayer", "multiplayer", "settings", "exit"],
	"singleplayer" : ["back", "start_game"],
	"multiplayer" : ["back"],
	"settings" : ["back"]
}

var STATES = {
	"main_menu" : main_menu,
	"singleplayer" : singleplayer,
	"multiplayer" : multiplayer_state,
	"settings" : settings
}

signal setting_menu_open
signal setting_menu_exit
signal singleplayer_open
signal singleplayer_back
signal start_singleplayer_game
signal multiplayer_open
signal multiplayer_back
signal exit_game

func get_hand(id : String) -> Array:
	return MENU_HANDS.get(id)

# returns the new menu state
func select_option(current_state : String, id : String) -> String:
	return STATES.get(current_state).call(id)

func main_menu(id : String) -> String:
	match id:
		"exit":
			exit_game.emit()
			"main_menu"
		"settings":
			setting_menu_open.emit()
		"singleplayer":
			singleplayer_open.emit()
		"multiplayer":
			multiplayer_open.emit()
	return id

func settings(id : String) -> String:
	match id:
		"back":
			setting_menu_exit.emit()
			return "main_menu"
	return "main_menu"

func singleplayer(id : String) -> String:
	match id:
		"back":
			singleplayer_back.emit()
			return "main_menu"
		"start_game":
			start_singleplayer_game.emit()
			return "main_menu"
	return "main_menu"

func multiplayer_state(id : String) -> String:
	match id:
		"back":
			multiplayer_back.emit()
			return "main_menu"
	return "main_menu"
	
