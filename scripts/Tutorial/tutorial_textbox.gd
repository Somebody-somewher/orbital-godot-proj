extends Node2D
class_name Textbox

@onready var label: Label = $Panel/MarginContainer/Label
@onready var tooltip : HBoxContainer = $Panel/Control/HBoxContainer

var tweening : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func display_text(str : String):
	tooltip.visible = false
	#preexisting tween from previous text
	if tweening and tweening.is_running():
		tweening.kill()
	label.visible_characters = 0
	label.text = str
	
	AudioManager.talk(str.length()/20)
	tweening = get_tree().create_tween()
	tweening.parallel().tween_property(label, "visible_characters", str.length(), 0.3)
	await tweening.finished
	tooltip.visible = true
