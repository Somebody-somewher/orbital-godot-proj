extends Object
class_name CardPackChooser

var player_uuid_to_packid : Dictionary[String, int] = {}
var packid_to_player_uuid : Dictionary[int, String] = {}

var _finalized_pack_choices : Callable
var _update_pack_choosen_ui : Callable

func _init(_update_pack_choosen_ui : Callable, _finalized_pack_choices : Callable) -> void:
	#TODO: ALSO SHOULD BE ABLE TO REMOVE THIS SINCE BY TAKING THE CARDPACKS AS INPUT
	# FROM THE SERVER'S CARDPACK GENERATOR
	Signalbus.connect("server_update_chooser", reset_chooser)
	Signalbus.connect("server_pack_choosing_end", finalize_pack_choices)

	PlayerManager.forEachPlayer(func(pi : PlayerInfo): \
		player_uuid_to_packid.get_or_add(pi.getPlayerUUID(), -1))
		
	self._finalized_pack_choices = _finalized_pack_choices
	self._update_pack_choosen_ui = _update_pack_choosen_ui

# TODO: Should be called once the PackManager receives packs instead
# PACKID DOESNT GET UPDATED. THIS CLASS IS CALCULATING ID SEPARATELY, ERROR PRONE


# Called by Server's CardPackGenerator found in CardLoader
func reset_chooser(pack_ids : Array[int]) -> void:
	for key in player_uuid_to_packid.keys():
		player_uuid_to_packid[key] = -1
	
	packid_to_player_uuid = {}
	for id in pack_ids:
		packid_to_player_uuid[id] = ""

func player_choose_pack(player_uuid : String, packid : int) -> bool:
	if player_uuid_to_packid[player_uuid] != -1:
		return false
	
	if packid not in  packid_to_player_uuid.keys():
		return false
	
	# If the player previously selected a pack, unselect it
	
	#packid_to_player_uuid[player_uuid_to_packid[player_uuid]] = ""
	# TODO: unselect pack visually lol
	
	player_uuid_to_packid[player_uuid] = packid
	packid_to_player_uuid[packid] = player_uuid
	
	print(_update_pack_choosen_ui)
	print(PlayerManager.uuid_to_players[player_uuid].getColor())
	PlayerManager.forEachPlayer(func(pi : PlayerInfo): \
		print(pi.getPlayerId());\
		_update_pack_choosen_ui.call(pi.getPlayerId(), packid, PlayerManager.uuid_to_players[player_uuid].getColor()))
	
	
	Signalbus.emit_signal("end_turn", player_uuid)
	return true
	
func finalize_pack_choices() -> void:
	PlayerManager.forEachPlayer(func(pi : PlayerInfo): \
		if player_uuid_to_packid[pi.getPlayerUUID()] == -1:\
			for packid in packid_to_player_uuid.keys(): \
				if packid_to_player_uuid[packid] == "": \
					player_choose_pack(pi.getPlayerUUID(), packid); break)
					
	PlayerManager.forEachPlayer(func(pi : PlayerInfo):
		
		# Server update choice
		var server_mem = CardLoader.card_mem as ServerCardMemory
		server_mem.record_player_cardpack_choice(player_uuid_to_packid[pi.getPlayerUUID()], pi.getPlayerUUID(), ); \
		
		_finalized_pack_choices.call(pi.getPlayerId(), player_uuid_to_packid[pi.getPlayerUUID()]))

#func reset() -> void:
	#player_uuid_to_packid.clear()
	#packid_to_player_uuid.clear()
#func check_all_players_select_packs() -> void:
	#var is_check := true
	#PlayerManager.forEachPlayer(func(pi : PlayerInfo): \
		#if player_uuid_to_packid[pi.getPlayerUUID()] == -1: \
			#is_check = false)
	
