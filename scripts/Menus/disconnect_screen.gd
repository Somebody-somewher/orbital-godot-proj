extends Control
class_name DisconnectScreen

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var label: Label = $DcMsg/Label

var time_since_switch : float = 0
var state = 0

func _ready() -> void:
	visible = false
	set_process(false)

func display()-> void:
	visible = true
	animation_player.play("pop_up")
	set_process(true)

func _process(delta: float) -> void:
	time_since_switch += delta
	if time_since_switch > 0.3:
		time_since_switch = 0
		state = (state + 1) % 4
		match(state):
			0:
				label.text = "Player Disconnected,\nReturning to menu"
			1:
				label.text = "Player Disconnected,\nReturning to menu."
			2:
				label.text = "Player Disconnected,\nReturning to menu.."
			3:
				label.text = "Player Disconnected,\nReturning to menu..."
		
