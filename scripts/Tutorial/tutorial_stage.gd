extends Node
class_name Tutorial

@export var round_manager : PackedScene
@export var settings : Dictionary


@onready var tutorial_dialogue: Control = $TutorialLayer/TutorialOverlay

enum TUT_STAGE { 
	PackOpen, PackOpenHighlight, PackOpenPost, UITeach, Compendium, 
	Combo, RoundEnd, Traders, Terrain, Destroy, End}

const TUT_HANDS = {
	TUT_STAGE.PackOpen : ["reset", "next"],
	TUT_STAGE.UITeach : ["reset", "next"],
	TUT_STAGE.Compendium : ["reset", "cow"],
	TUT_STAGE.Combo : ["reset", "chicken", "wheat"],
	TUT_STAGE.RoundEnd : ["reset", "wagon", "bank"],
	TUT_STAGE.Traders : ["reset", "store", "berry", "apple", "coconut"],
	TUT_STAGE.Terrain : ["reset", "shovel", "lilypad", "frog"],
	TUT_STAGE.Destroy : ["reset", "bomb"]
}

const TUT_DIALOGUE = {
	TUT_STAGE.PackOpen : 
		["Hi! Welcome Carditect, to the first step in curating your own little world!", 
		"See that Card Pack? Right click it and click the check mark to select it."],
	TUT_STAGE.PackOpenHighlight : 
		["Notice the outline around the pack? It means that only you can open it now.", 
		"In Multiplayer mode, you can see what packs your friends have already selected by the color of the outlines.",
		"Right click one last time to open it!"],
	TUT_STAGE.PackOpenPost : 
		["Look, you got two cards! Your hand will be displayed at the bottom of the screen.", 
		"Drag a card onto the board to play it, if you wish to cancel, right click while dragging.",
		"Play next to proceed, or reset if you want a recap!"],
	TUT_STAGE.UITeach : [
		"Your score is displayed on the top left, you want this to be as high as possible!", 
		"The top right is which round it currently is. In a real game, the bottom right would show the timer.",
		"Press ESC at any point in time to pull up the menu. Open the menu to progress!"],
	TUT_STAGE.Compendium : [
		"The compendium is a useful to to learn about new cards, click the book mark to open it.",
		"If you have a card in hand or on the board, middle click (your scroll wheel) to search it up directly"],
	TUT_STAGE.Combo : [
		"The most common way to earn points is to play two related cards near each other.", 
		"When you are hovering a card, you can see how many points placing cards will earn you.", 
		"Earn 3 points to progress. Note that cards have different range of effects!"],
	TUT_STAGE.RoundEnd : [
		"For the level I will provide you with a Round End button, which you will also get in Singleplayer",
		"In multiplayer, the round ends when the round timer is up.",
		"Some card have special effects each round. Using the cards provided, try to earn 5 points!"],
	TUT_STAGE.Traders : [
		"Traders are special cards that can sell other cards.", 
		"You can search 'sellable' and 'trader' in the Compendium to see these cards", 
		"When the round ends, all sellables in the trader's area of effect will be sold for points",
		"Sell all your fruit to proceed."],
	TUT_STAGE.Terrain : [
		"Cards labelled as 'Powers' are single use, and usually do something special.", 
		"A Shovel card converts tiles into water tiles. Earn 2 points to poceed"],
	TUT_STAGE.Destroy : [
		"Sabotage cards are fun, devastating gifts to your friends. You do have friends, don't you?", 
		"Destroy the dummy to proceed!"],
	TUT_STAGE.End : [
		"You should have all the knowledge you need to start, happy building!"]
}

# Called when the node enters the scene tree for the first time.
func setup(settings : Dictionary) -> void:
	self.settings = settings
	AudioManager.play_bgm("random")
	AudioManager.next_bgm = "random"
	CardLoader.setup()
	
	if multiplayer.is_server():
		var round_manager_instance : TutRoundCounter = round_manager.instantiate()
		round_manager_instance.set_up(settings)
		add_child(round_manager_instance)
		get_node("BoardManager").server_setup(settings)
	get_node("Camera2D").cam_enabled = false

func _ready() -> void:
	get_node("UILayer/PlayerUI/RoundTimerLabel").visible = false
	get_node("Camera2D").cam_enabled = false
	get_node("InputManager").camera_enabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#clear board, clear hand and respawn card pack with correct cards
func reset_stage():
	pass

#set up board to stage no, enable tooltips
func load_stage(no : int):
	pass

func create_tut_card(id_name) -> void:
	var instance = CardLoader.create_data_instance(id_name, -1)
	var player_uuid := PlayerManager.getCurrentPlayerUUID()
	instance.set_owner_uuid(player_uuid)
	var pos = Vector2((0 + 0.5) * 113, (0 + 0.5) * 113)
	(CardLoader.card_mem as ServerCardMemory).add_card_in_hand(instance, player_uuid, pos)
	
