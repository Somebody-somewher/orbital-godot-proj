extends Node
class_name Tutorial

@export var round_manager : PackedScene
@export var settings : Dictionary

var round_manager_instance :TutRoundCounter


@onready var player_hand: PlayerHand = $PlayerHand
@onready var tutorial_card_pack: TutorialPack = $CardManager/TutorialCardPack
@onready var tutorial_dialogue: Control = $TutorialLayer/TutorialOverlay
@onready var board_manager: TutorialBoard = $BoardManager
@onready var end_turn_button : Button = $UILayer/PlayerUI/EndTurn

var curr_stage := TUT_STAGE.PackOpen
# so that the next stage card is only created once
var can_create_next := false
var player_uuid

enum TUT_STAGE { 
	PackOpen, UITeach, Compendium, 
	Combo, RoundEnd, Traders, Terrain, Destroy, End, PackOpenHighlight, PackOpenPost}

const TUT_HANDS = {
	TUT_STAGE.PackOpen : ["reset", "next"],
	TUT_STAGE.UITeach : ["reset"],
	TUT_STAGE.Compendium : ["reset", "cow"],
	TUT_STAGE.Combo : ["reset", "chicken", "wheat_field"],
	TUT_STAGE.RoundEnd : ["reset", "wagon", "bank"],
	TUT_STAGE.Traders : ["reset", "store", "berry", "apple", "coconut"],
	TUT_STAGE.Terrain : ["reset", "shovel", "lilypad", "frog"],
	TUT_STAGE.Destroy : ["reset", "bomb"]
}

const TUT_DIALOGUE : Dictionary[int, Array] = {
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
		"Play 'Next' to proceed, or 'Reset' if you want a recap!"],
	TUT_STAGE.UITeach : [
		"Your score is displayed on the top left, you want this to be as high as possible!", 
		"The top right shows which round it is. In a real game, the bottom right would display the timer.",
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
		round_manager_instance = round_manager.instantiate()
		round_manager_instance.set_up(settings)
		add_child(round_manager_instance)
		get_node("BoardManager").server_setup(settings)
	get_node("Camera2D").cam_enabled = false
	load_stage(TUT_STAGE.PackOpen)
	player_uuid = PlayerManager.getCurrentPlayerUUID()

func _ready() -> void:
	get_node("UILayer/PlayerUI/RoundTimerLabel").visible = false
	get_node("Camera2D").cam_enabled = false
	get_node("InputManager").camera_enabled = false
	Signalbus.tut_pack_selected.connect(pack_selected)
	Signalbus.server_pack_choosing_end.connect(pack_opened)
	Signalbus.tut_escape_menu_opened.connect(escape_menu_opened)
	Signalbus.tut_close_compendium.connect(compendium_viewed)
	Signalbus.reset_tutorial.connect(reload_stage)
	Signalbus.next_tutorial_stage.connect(pass_stage)
	Signalbus.update_score_ui.connect(check_score)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func reload_stage():
	reset_stage()
	load_stage(curr_stage)

func pass_stage():
	if(curr_stage == TUT_STAGE.Destroy):
		tutorial_dialogue.start_dialogue(TUT_DIALOGUE.get(TUT_STAGE.End))
		await get_tree().create_timer(5).timeout
		SceneManager.back_to_menu()
		return
	reset_stage()
	await get_tree().create_timer(.1).timeout
	load_stage(curr_stage + 1)

#clear board, clear hand and respawn card pack with correct cards
func reset_stage():
	if curr_stage == TUT_STAGE.Terrain:
		for i in range(3):
			for j in range(3):
				board_manager._change_terrain("Grass", Vector2i(i,j))
	player_hand.discard_hand()
	destroy_stage()
	await get_tree().create_timer(.1).timeout
	reset_round_counter()
	tutorial_card_pack.regenerate()

#set up board to stage no, enable tooltips
func load_stage(no : int):
	end_turn_button.visible = false
	can_create_next = true
	curr_stage = no
	tutorial_card_pack.cards = TUT_HANDS[no]
	match no:
		TUT_STAGE.PackOpen:
			can_create_next = false
		TUT_STAGE.UITeach:
			pass
		TUT_STAGE.Compendium:
			place_on_tut_board("bees", Vector2i(0,0))
			place_on_tut_board("castle", Vector2i(1,1))
			place_on_tut_board("diamond", Vector2i(2,2))
		TUT_STAGE.Combo:
			pass
		TUT_STAGE.RoundEnd:
			end_turn_button.visible = true
		TUT_STAGE.Traders:
			end_turn_button.visible = true
		TUT_STAGE.Terrain:
			pass
		TUT_STAGE.Destroy:
			place_on_tut_board("dummy", Vector2i(1,1))
	
	tutorial_dialogue.start_dialogue(TUT_DIALOGUE.get(no))

func pack_selected():
	if curr_stage == TUT_STAGE.PackOpen and can_create_next:
		tutorial_dialogue.start_dialogue(TUT_DIALOGUE.get(TUT_STAGE.PackOpenHighlight))

func pack_opened():
	if curr_stage == TUT_STAGE.PackOpen and can_create_next:
		tutorial_dialogue.start_dialogue(TUT_DIALOGUE.get(TUT_STAGE.PackOpenPost))
	
func escape_menu_opened():
	if curr_stage == TUT_STAGE.UITeach and can_create_next:
		tutorial_card_pack.create_tut_card("next")
		can_create_next = false
	
func compendium_viewed():
	if curr_stage == TUT_STAGE.Compendium and can_create_next:
		tutorial_card_pack.create_tut_card("next")
		can_create_next = false

func check_score(score : int):
	if !can_create_next:
		return
	if curr_stage == TUT_STAGE.Combo and score >= 3:
		pass
	elif curr_stage == TUT_STAGE.RoundEnd and score >= 5:
		pass
	elif curr_stage == TUT_STAGE.Traders and score >= 7:
		pass
	elif curr_stage == TUT_STAGE.Terrain and score >= 2:
		pass
	else:
		return
	tutorial_card_pack.create_tut_card("next")
	can_create_next = false
	end_turn_button.visible = false

func destroy_stage():
	board_manager.matrix_data.clear_board()

func reset_round_counter():
	round_manager_instance.round_counter_reset()
	round_manager_instance.score_manager.set_player_score(0, player_uuid)
	pass
	
func create_next_card():
	tutorial_card_pack.create_tut_card("next")

func place_on_tut_board(card_name : String, pos : Vector2i, run_on_place : bool = false):
	var data = CardLoader.create_data_instance(card_name, -1)
	(CardLoader.card_mem as ServerCardMemory).func_register_events.call(data)
	board_manager._place_placeable(data, pos, false)
	
