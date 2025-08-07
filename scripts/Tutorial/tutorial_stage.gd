extends Node
class_name Tutorial

@export var round_manager : PackedScene
@export var settings : Dictionary


@onready var tutorial_dialogue: Control = $TutorialLayer/TutorialOverlay

enum TUT_STAGE { 
	PackOpen, UITeach, Compendium, 
	Combo, RoundEnd, Traders, Terrain, Destroy}

const TUT_HANDS = {
	TUT_STAGE.PackOpen : ["reset", "next"],
	TUT_STAGE.UITeach : ["reset", "next"],
	TUT_STAGE.Compendium : ["reset", "cow"],
	TUT_STAGE.Combo : ["reset", "chicken", "wheat"],
	TUT_STAGE.RoundEnd : ["reset", "wagon"],
	TUT_STAGE.Traders : ["reset", "store", "berry", "berry"],
	TUT_STAGE.Terrain : ["reset", "shovel", "lilypad", "frog"],
	TUT_STAGE.Destroy : ["reset", "bomb"]
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
	
