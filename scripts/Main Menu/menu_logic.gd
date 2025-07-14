extends Node
class_name MenuLogic
# manages behaviour, basically a scene manager

@onready var player_hand_ref: Node2D = $"../PlayerHand"

const MENU_HANDS = {
	"main_menu" : ["singleplayer", "multiplayer", "settings", "exit"],
	"singleplayer" : ["back", "start_game"],
	"multiplayer" : ["back", "host", "join"],
	"multihost" : ["back", "start_game"],
	"multijoin" : ["back"],
	"settings" : ["back"]
}

var STATES = {
	"main_menu" : main_menu,
	"singleplayer" : singleplayer,
	"multiplayer" : multiplayer_state,
	"multihost" : multiplayer_host,
	"multijoin" : multiplayer_join,
	"settings" : settings
}

signal setting_menu_open
signal setting_menu_exit
signal singleplayer_open
signal singleplayer_back
signal start_singleplayer_game
signal multiplayer_open
signal multiplayer_back
signal multihost_open
signal multihost_back
signal start_multiplayer_game
signal multijoin_open
signal multijoin_back
signal exit_game

func get_hand(id : String) -> Array:
	for cardid in MENU_HANDS.get(id):
		spawn_card(cardid)
	return MENU_HANDS.get(id)

# returns the new menu state
func select_option(current_state : String, id : String) -> String:
	player_hand_ref.discard_hand()
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

func singleplayer(id : String) -> String:
	match id:
		"back":
			singleplayer_back.emit()
		"start_game":
			start_singleplayer_game.emit()
	return "main_menu"

func multiplayer_state(id : String) -> String:
	match id:
		"back":
			multiplayer_back.emit()
			return "main_menu"
		"host":
			multihost_open.emit()
			return "multihost"
		"join":
			multijoin_open.emit()
			return "multijoin"
	return "main_menu"

func multiplayer_host(id : String) -> String:
	match id:
		"back":
			multihost_back.emit()
		"start_game":
			NetworkManager.set_up()
			start_multiplayer_game.emit()
	return "multiplayer"

func multiplayer_join(id : String) -> String:
	match id:
		"back":
			multijoin_back.emit()
	return "multiplayer"

# for add cards back into hand
func spawn_card(id_name : String) -> void:
	var building_data := CardLoader.get_building_data(id_name)
	var new_card = MenuCard.new_menucard(building_data, CardLoader.buildingcard_img)
	self.add_child(new_card)
	new_card.global_position = Vector2i(800,450)
	Signalbus.emit_signal("register_to_cardmanager", new_card)
	player_hand_ref.add_card_to_hand(new_card)
