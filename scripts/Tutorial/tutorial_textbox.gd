extends Node2D
class_name Textbox

@onready var label: Label = $Panel/MarginContainer/Label
@onready var tooltip : HBoxContainer = $Panel/Control/HBoxContainer

var tweening : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)

func display_text(str : String):
	tooltip.visible = false
	#preexisting tween from previous text
	if tweening.is_running():
		tweening.kill()
	label.visible_characters = 0
	label.text = str
	
	tweening = get_tree().create_tween()
	tweening.parallel().tween_property(label, "visible_characters", 0, str.length())
	await tweening.finished
	tooltip.visible = true
