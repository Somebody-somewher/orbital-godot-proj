extends Object
class_name CardPackChooser

var num_packs_created := 0

var player_uuid_to_packindex : Dictionary[String, int] = {}
var packindex_to_player_uuid : Dictionary[int, String] = {}
var packindex_to_packid : Dictionary[int, int]

var _finalized_pack_choices : Callable
var _update_pack_choosen_ui : Callable

func _init(_update_pack_choosen_ui : Callable, _finalized_pack_choices : Callable) -> void:
	#TODO: ALSO SHOULD BE ABLE TO REMOVE THIS SINCE BY TAKING THE CARDPACKS AS INPUT
	# FROM THE SERVER'S CARDPACK GENERATOR
	Signalbus.connect("server_update_chooser", reset_chooser)
	Signalbus.connect("server_pack_choosing_end", finalize_pack_choices)

	PlayerManager.forEachPlayer(func(pi : PlayerInfo): \
		player_uuid_to_packindex.get_or_add(pi.getPlayerUUID(), -1))
		
	self._finalized_pack_choices = _finalized_pack_choices
	self._update_pack_choosen_ui = _update_pack_choosen_ui

# TODO: Should be called once the PackManager receives packs instead
# PACKID DOESNT GET UPDATED. THIS CLASS IS CALCULATING ID SEPARATELY, ERROR PRONE


# Called by Server's CardPackGenerator found in CardLoader
func reset_chooser(num_packs : int) -> void:
	for key in player_uuid_to_packindex.keys():
		player_uuid_to_packindex[key] = -1
	
	packindex_to_player_uuid = {}
	for index in range(num_packs):
		packindex_to_player_uuid[index] = ""
		packindex_to_packid[index] = num_packs_created + index
	num_packs_created += num_packs

func player_choose_pack(player_uuid : String, pack_index : int) -> bool:
	if player_uuid_to_packindex[player_uuid] != -1:
		return false
	
	if pack_index >= player_uuid_to_packindex.values().size() || pack_index < 0:
		return false
	
	packindex_to_player_uuid[player_uuid_to_packindex[player_uuid]] = ""
	
	player_uuid_to_packindex[player_uuid] = pack_index
	packindex_to_player_uuid[pack_index] = player_uuid
	Signalbus.emit_signal("end_turn", player_uuid)
	
	PlayerManager.forEachPlayer(func(pi : PlayerInfo): \
		_update_pack_choosen_ui.call(pi.getPlayerId(), pack_index, PlayerManager.uuid_to_players[player_uuid].getColor()))
	
	return true
	
func finalize_pack_choices() -> void:
	PlayerManager.forEachPlayer(func(pi : PlayerInfo): \
		if player_uuid_to_packindex[pi.getPlayerUUID()] == -1:\
			for pack_index in packindex_to_player_uuid.keys(): \
				if packindex_to_player_uuid[pack_index] == "": \
					player_choose_pack(pi.getPlayerUUID(), pack_index); break)
					
	PlayerManager.forEachPlayer(func(pi : PlayerInfo):
		
		# Server update choice
		CardLoader.server_card_memory.record_cardpack_choice(pi.getPlayerUUID(), player_uuid_to_packindex[pi.getPlayerUUID()]); \
		
		# Client local update choice
		CardLoader.cardpack_gen.update_local_cardpack_choice.rpc_id(pi.getPlayerId(), \
			player_uuid_to_packindex[pi.getPlayerUUID()], packindex_to_packid[player_uuid_to_packindex[pi.getPlayerUUID()]]);\
		
		_finalized_pack_choices.call(pi.getPlayerId(), packindex_to_packid[player_uuid_to_packindex[pi.getPlayerUUID()]]))

#func check_all_players_select_packs() -> void:
	#var is_check := true
	#PlayerManager.forEachPlayer(func(pi : PlayerInfo): \
		#if player_uuid_to_packid[pi.getPlayerUUID()] == -1: \
			#is_check = false)
	
