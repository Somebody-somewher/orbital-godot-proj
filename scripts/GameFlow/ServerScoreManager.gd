extends Object
class_name ScoreManager

var scores : Dictionary[String, int]
var medals : Dictionary[String, Array]

var ranking : Array[String]

var end_score : int = 10
var end_medals : int = 5

var is_poll_first := false
var game_can_end := false

signal game_end(player_uuid : String, player_scores : Dictionary[String, int], player_medals : Dictionary[String, Array])

func _init(settings : Dictionary) -> void:
	PlayerManager.forEachPlayer(func(pi : PlayerInfo):
		scores[pi.getPlayerUUID()] = 0;\
		medals[pi.getPlayerUUID()] = [];
		ranking.append(pi.getPlayerUUID()) )
		
	Signalbus.connect("add_score", adjust_score)
	
	if settings.has('win_rounds'):
		self.end_score = settings["win_rounds"]
	
	if settings.has('win_medals'):
		self.end_medals = end_medals
	
func adjust_score(score_to_add : int, player_uuid : String) -> void:
	#print("SCOREMANAGER: ", player_uuid, " ", score_to_add)
	scores[player_uuid] += score_to_add
	ranking.sort_custom(rank_player)
	Signalbus.emit_multiplayer_signal.rpc_id(PlayerManager.getPeerID_from_UUID(player_uuid), "update_score_ui"\
		,[scores[player_uuid]])
	check_if_end(player_uuid, scores[player_uuid], medals[player_uuid])

# This runs if a player hits winning conditions within the Build Phase (but not start or end of round)
func check_if_end(player_uuid : String, updated_score : int, updated_medals : Array) -> void:
	if (end_score != -1 and updated_score >= end_score) or \
		end_medals != -1 and updated_medals.size() >= end_medals:
			
			if !is_poll_first:
				# Ends game immediately by declaring winner
				emit_signal("game_end", player_uuid, scores, medals)
			else:
				# Wait until all events have been processed before finding a winner
				game_can_end = true

func rank_player(original_winner : String, new_winner : String) -> bool:
	
	# Medals are always priority (even if score is the game end condition)
	var new_win_medals := len(medals[new_winner])
	var old_win_medals := len(medals[original_winner])
	if new_win_medals > old_win_medals:
		return false
	elif new_win_medals < old_win_medals:
		return true
			
	var new_win_score := len(scores[new_winner])
	var old_win_score := len(scores[original_winner])
	if new_win_score > old_win_score:
		return false
	elif new_win_score < old_win_score:
		return true
	
	return true

func set_is_poll_first(value : bool) -> void:
	is_poll_first = value
# This runs after the Start or End of Round to check for a winner (if any)
func query_for_winner(must_end : bool) -> void:
	if game_can_end or must_end:
		emit_signal("game_end", ranking[0], scores, medals)
		
	
