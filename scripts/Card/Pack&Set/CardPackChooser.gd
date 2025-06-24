extends Object
class_name CardPackChooser

var player_uuid_to_packid : Dictionary[String, int] = {}
var packid_to_player_uuid : Dictionary[int, String] = {}

var _remove_other_packs : Callable

func _init(_remove_other_packs : Callable) -> void:
	Signalbus.connect("server_update_chooser", reset_chooser)

	PlayerManager.forEachPlayer(func(pi : PlayerInfo): \
		player_uuid_to_packid.get_or_add(pi.getPlayerUUID(), -1))
	self._remove_other_packs = _remove_other_packs

# Called by Server's CardLoader
func reset_chooser(num_packs : int) -> void:
	for key in player_uuid_to_packid.keys():
		player_uuid_to_packid[key] = -1
	
	packid_to_player_uuid = {}
	for index in range(num_packs):
		packid_to_player_uuid.get_or_add(index, "")

func player_choose_pack(player_uuid : String, pack_id : int) -> bool:
	if player_uuid_to_packid[player_uuid] != -1:
		return false
	
	if pack_id >= player_uuid_to_packid.values().size() || pack_id < 0:
		return false
	
	player_uuid_to_packid[player_uuid] = pack_id
	packid_to_player_uuid[pack_id] = player_uuid
	CardLoader.server_card_memory.record_cardpack_choice(player_uuid, pack_id)
	Signalbus.emit_signal("end_turn", player_uuid)
	return true

func remove_other_packs() -> void: 
	PlayerManager.forEachPlayer(func(pi : PlayerInfo): \
		if player_uuid_to_packid[pi.getPlayerUUID()] == -1:\
			for pack_id in packid_to_player_uuid.keys(): \
				if packid_to_player_uuid[pack_id] == "": \
					player_choose_pack(pi.getPlayerUUID(), pack_id); break;\
	
		_remove_other_packs.call(pi.getPlayerId(), player_uuid_to_packid[pi.getPlayerUUID()]))

#func check_all_players_select_packs() -> void:
	#var is_check := true
	#PlayerManager.forEachPlayer(func(pi : PlayerInfo): \
		#if player_uuid_to_packid[pi.getPlayerUUID()] == -1: \
			#is_check = false)
	
