extends Object
class_name ScoreManager

var scores : Dictionary[String, int]
var medals : Dictionary[String, Array]

var end_score : int
var end_medals : int

signal game_end(player_uuid : String, player_scores : Dictionary[String, int], player_medals : Dictionary[String, Array])

func _init(end_score := 200, end_medals := 5) -> void:
	PlayerManager.forEachPlayer(func(pi : PlayerInfo):
		scores[pi.getPlayerUUID()] = 0;\
		medals[pi.getPlayerUUID()] = [];)
		
	Signalbus.connect("add_score", adjust_score)
	self.end_score = end_score
	self.end_medals = end_medals
	
func adjust_score(score_to_add : int, player_uuid : String) -> void:
	scores[player_uuid] += score_to_add
	Signalbus.emit_multiplayer_signal.rpc_id(PlayerManager.getPeerID_from_UUID(player_uuid), "update_score_ui"\
		,[scores[player_uuid]])
	
	
func check_if_end(player_uuid : String, updated_score : int, updated_medals : Array) -> void:
	if (end_score != -1 and updated_score >= end_score) or \
		end_medals != -1 and updated_medals.size() >= end_medals:
		emit_signal("game_end", player_uuid, scores, medals)

		
