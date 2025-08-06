extends Node
class_name Tutorial

@export var round_manager : PackedScene
@export var settings : Dictionary

enum TUT_STAGE { 
	PackOpen, UITeach, Compendium, 
	Combo, RoundEnd, Traders, Terrain, Destroy}

const TUT_HANDS = {
	0 : ["reset", "next"],
	1 : ["reset", "next"],
	2 : ["reset", "cow"],
	3 : ["reset", "chicken", "wheat"],
	4 : ["reset", "wagon"],
	5 : ["reset", "store", "berry", "berry"],
	6 : ["reset", "shovel", "lilypad", "frog"],
	7 : ["reset", "bomb"]
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

#func _ready() -> void:
	#AudioManager.play_bgm("random")
	#AudioManager.next_bgm = "random"
	#CardLoader.setup()
	#NetworkManager.set_up()

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
