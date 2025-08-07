extends Object
class_name ScoreManager

# The inner Dict has both actual score value and medals
var player_scores : Dictionary[String, Dictionary]
#var medals : Dictionary[String, Array]

var ranking : Array[String]

var end_score : int = 100
var end_medals : int = 5

var is_poll_first := false
var game_can_end := false

signal game_end(player_uuid : String, player_scores : Dictionary[String, int], player_medals : Dictionary[String, Array])

func _init(settings : Dictionary) -> void:
	PlayerManager.forEachPlayer(func(pi : PlayerInfo):
		#scores[pi.getPlayerUUID()] = 0;\
		#medals[pi.getPlayerUUID()] = [];
		player_scores[pi.getPlayerUUID()] = {"score" : 0, "medals" : []}
		ranking.append(pi.getPlayerUUID()) )
		
	Signalbus.add_score.connect(adjust_score)
	
	if settings.has('win_rounds'):
		self.end_score = settings["win_rounds"]
	
	if settings.has('win_medals'):
		self.end_medals = settings["win_medals"]
		
	if settings.has('win_score'):
		self.end_score = settings["win_score"]
	
func adjust_score(score_to_add : int, player_uuid : String) -> void:
	#print("SCOREMANAGER: ", player_uuid, " ", score_to_add)
	player_scores[player_uuid]["score"] += score_to_add
	ranking.sort_custom(rank_player)
	Signalbus.emit_multiplayer_signal.rpc_id(PlayerManager.getPeerID_from_UUID(player_uuid), "update_score_ui"\
		,[player_scores[player_uuid]["score"]])
	check_if_end(player_uuid, player_scores[player_uuid]["score"], player_scores[player_uuid]["medals"])

# This runs if a player hits winning conditions within the Build Phase (but not start or end of round)
func check_if_end(player_uuid : String, updated_score : int, updated_medals : Array) -> void:
	if (end_score != -1 and updated_score >= end_score) or \
		end_medals != -1 and updated_medals.size() >= end_medals:
			
			if !is_poll_first:
				# Ends game immediately by declaring winner
				emit_signal("game_end", ranking, player_scores)
			else:
				# Wait until all events have been processed before finding a winner
				game_can_end = true

func rank_player(original_winner : String, new_winner : String) -> bool:
	
	# Medals are always priority (even if score is the game end condition)
	var new_win_medals := len(player_scores[new_winner]["medals"])
	var old_win_medals := len(player_scores[original_winner]["medals"])
	if new_win_medals > old_win_medals:
		return false
	elif new_win_medals < old_win_medals:
		return true
			
	var new_win_score : int = player_scores[new_winner]["score"]
	var old_win_score : int = player_scores[original_winner]["score"]
	if new_win_score > old_win_score:
		return false
	elif new_win_score < old_win_score:
		return true
	
	return true

func set_is_poll_first(value : bool) -> void:
	is_poll_first = value
	
# This runs after the Start or End of Round to check for a winner (if any)
# Must end is true if the game must end and we need to find the "closest" winning player
func query_for_winner(must_end : bool) -> void:
	if game_can_end or must_end:
		game_end.emit(ranking, player_scores)

func reset() -> void:
	Signalbus.add_score.disconnect(adjust_score)
	
