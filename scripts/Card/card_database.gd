const CARDS = {#Visual Name, Effect Pattern, List of entities "score", stackables
	"dummy" : ["Dummy", "3x3", [], []],
	"cow" : ["Cow", "med orth cross", [["cow", 20], ["flower", 10], ["cute_dummy", 10]], []],
	"cute_dummy" : ["Cute Dummy", "small diagonal cross", [["cow", 10]], []],
	"flower" : ["Flower", "", [], []],
	"rock" : ["Rock", "circle", [], []],
	"forest" : ["Forest", "", [], [], ],
	"mountain" : ["mountain", "", [], []],
	"singleplayer" : ["Singleplayer", "", [], []],
	"multiplayer" : ["multiplayer", "", [], []],
	"exit" : ["Exit", "", [], []],
	"start_game" : ["Start Game", "", [], []],
	"settings" : ["Options", "", [], []],
	"back" : ["back", "", [], []]
	}

const SETS = {#arr of card type, no. of cards
	"Dummy Set" : [["cute_dummy", 2]],
	"Big Cow Set" : [["cow", 7]],
	"Nature Set" : [["flower", 3], ["rock", 3], ["forest", 3]],
	"Alcohol" : [["bar", 1],["brewery", 1],["trash", 2]],
	"Worship" : [["temple", 1],["obelisk", 2]],
	"Homeless" : [["hobo_tent", 3],["campfire", 1],["trash", 1]],
	"Lumber" : [["lumber_mill", 1],["beaver", 2]],
	"Town Square" : [["belltower", 1],["fountain", 1],["statue", 1]],
	"Carrot" : [["carrots", 4], ["pig", 1]],
	"Empire" : [["castle", 1],["tower",2]],
	"Warfare" : [["cannon", 2],["knight",2]],
	"Chicken" : [["chicken", 3],["wheat_field",1]],
	"Circus" : [["circus", 1],["scryer_tent",1], ["wagon",1]],
	"Village" : [["cottage", 3],["well",1]],
	"Farm" : [["farmhouse", 1],["wheat_field",2], ["mill",1]],
	"Self Sustaining" : [["garden", 2],["carrots",2], ["market",1]],
	"Curiosities" : [["summoning_circle", 1],["obelisk",3]],
	"Animal Farm" : [["pig", 2],["cow",2], ["chicken", 2]],
	"RATS" : [["rat", 4],["rat_swarm",1]],
	"Rat King" : [["rat_king", 1],["rats",2]],
	"Wheat" : [["wheat_field", 2],["silo",1], ["chicken",1]],
	"Market" : [["market", 3],["wagon",1]],
	"Housing" : [["hut", 2],["cottage",2], ["farmhouse", 1]],
	"Modern" : [["bank", 1],["store",1], ["cottage",2]],
}

const AOE = { #arr of relative coordinates as areas of influence
	"3x3" : [[-1, -1], [0, -1], [1, -1], [-1, 0], [0, 0], [1, 0], [-1, 1], [0, 1], [1, 1]],
	"small orth cross" : [[0, -1], [-1, 0], [0, 0], [1, 0], [0, 1]],
	"small diagonal cross" : [[-1, -1], [1, -1], [0, 0], [-1, 1], [1, 1]],
	"med orth cross" : [[0, -1], [-1, 0], [0, 0], [1, 0], [0, 1], [0, -2], [-2, 0], [2, 0], [0, 2]],
	"" : [[0,0]],
	"circle" : [[0, 0], [1, 2], [0, 2], [-1, 2], [1, -2], [0, -2], [-1, -2],[2, 1], [2, 0], [2, -1],[-2, 1], [-2, 0], [-2, -1]]
}

# Set queries
static func get_set_cards_by_set_id(id: String) -> Array:
	return SETS.get(id)

# AOE queries
static func get_aoe_by_id(aoe : String) -> Array[Vector2i] :
	var arr = AOE.get(aoe)
	var ret_arr : Array[Vector2i] = []
	if arr == null:
		return []
	for tile in arr:
		ret_arr.append(Vector2i(tile[0], tile[1]))
	return ret_arr

# CARD/BUILDING Queries
static func get_card_name_by_id(id: String) -> String:
	var card = CARDS.get(id)
	if card:
		return card[0]
	else:
		return ""

static func get_card_scorers_by_id(id: String) -> Array:
	var card = CARDS.get(id)
	if card:
		return card[2]
	else:
		return []

static func get_card_stackables_by_id(id: String) -> Array:
	var card = CARDS.get(id)
	if card:
		return card[3]
	else:
		return []

static func get_card_aoe_by_id(id: String) -> Array[Vector2i]:
	var card = CARDS.get(id)
	if card:
		return get_aoe_by_id(card[1])
	else:
		return []

static func get_building_score(building_on_board : String, building_placed : String) -> int :
	var scorers = get_card_scorers_by_id(building_placed)
	for score_pair in scorers:
		if score_pair[0] == building_on_board:
			return score_pair[1]
	return 0

static func get_tile_score(buildings_on_tile : Array[String], building_placed : String) -> int :
	var scorers = get_card_scorers_by_id(building_placed)
	var acc_score = 0
	for score_pair in scorers:
		if score_pair[0] in buildings_on_tile:
			acc_score += score_pair[1]
	return acc_score
