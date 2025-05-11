const TERRAIN = { #Visual Name, Base Score, sprite_path (TODO: replace with spritesheet_cell_id or sth)
	"Grass" : ["Grass", 0],
	"Water" : ["Water", 0],
	"Desert" : ["Desert", -1]
}

const CARDS = {#Visual Name, Effect Pattern, List of entities affected
	"dummy" : ["Dummy", "3x3", []],
	"cow" : ["Cow", "small orth cross", []],
	"cute_dummy" : ["Cute Dummy", "small diagonal cross", []],
}

const SETS = {#arr of card type, no. of cards
	"Dummy Set" : [["dummy", 2]],
	"Big Dummy Set" : [["dummy", 4]],
	"Cow Set" : [["cow", 3]],
	"Cute Dummy Set" : [["cute_dummy", 5]],
}

const AOE = { #arr of relative coordinates as areas of influence
	"3x3" : [[-1, -1], [0, -1], [1, -1], [-1, 0], [0, 0], [1, 0], [-1, 1], [0, 1], [1, 1]],
	"small orth cross" : [[0, -1], [-1, 0], [0, 0], [1, 0], [0, 1]],
	"small diagonal cross" : [[-1, -1], [1, -1], [0, 0], [-1, 1], [1, 1]],
	"med orth cross" : [[0, -1], [-1, 0], [0, 0], [1, 0], [0, 1], [0, -2], [-2, 0], [2, 0], [0, 2]]
}

static func getTerrain(terrain_id : String) -> Array:
	return TERRAIN.get(terrain_id, TERRAIN["Grass"])
	
