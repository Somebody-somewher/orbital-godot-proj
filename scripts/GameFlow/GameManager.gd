extends Node
class_name GameManager
# Directs flow of the game. Separate from the RoundManager. 
# Likely the GameManager will need to take control to pause game flow to show animations 
# or pause the game whenever a player disconnects 

@export var round_manager : PackedScene
@export var settings : Dictionary

func set_up_settings(settings : Dictionary) -> void:
	self.settings = settings
	pass

func _ready() -> void:
	AudioManager.play_bgm("plains")

	CardLoader.setup()
	if multiplayer.is_server():
		var round_manager_instance : RoundCounter = round_manager.instantiate()
		if settings != null:
			round_manager_instance.set_up(settings)
		add_child(round_manager_instance)
	
	
