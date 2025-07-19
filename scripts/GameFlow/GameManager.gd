extends Node
class_name GameManager
# Directs flow of the game. Separate from the RoundManager. 
# Likely the GameManager will need to take control to pause game flow to show animations 
# or pause the game whenever a player disconnects 

@export var round_manager : PackedScene
@export var settings : Dictionary


static var is_gameplay_paused := false
static var is_everything_paused := false

func set_up_settings(settings : Dictionary) -> void:
	self.settings = settings
	pass

func _ready() -> void:
	AudioManager.play_bgm("plains")
	Signalbus.server_create_packs.connect(pause_gameplay)
	Signalbus.server_pack_choosing_end.connect(unpause_gameplay)
	CardLoader.setup()
	if multiplayer.is_server():
		var round_manager_instance : RoundCounter = round_manager.instantiate()
		if settings != null:
			round_manager_instance.set_up(settings)
		add_child(round_manager_instance)
	
	
@rpc("any_peer", "call_local")
func pause_gameplay() -> void:
	_set_pause_gameplay(true)

@rpc("any_peer", "call_local")
func unpause_gameplay() -> void:
	_set_pause_gameplay(false)

static func _set_pause_gameplay(setting : bool) -> void:
	is_gameplay_paused = setting
