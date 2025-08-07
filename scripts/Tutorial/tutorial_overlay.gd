extends Control
class_name TutorialOverlay

@onready var text_anim: AnimationPlayer = $TextAnim
@onready var cow_anim: AnimationPlayer = $CowAnim
@onready var hide_anim: AnimationPlayer = $HideAnim
@onready var label: Label = $Textbox/Panel/MarginContainer/Label
@onready var textbox: Textbox = $Textbox

var curr_dialogue := []
var curr_index := 0
var in_dialogue := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#start_dialogue(["1","2","3","14","5","6","7","8","9","0","1"])
	self.visible = true
	hide_anim.play("exit")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if !in_dialogue:
		return
	if Input.is_action_just_pressed("leftMouseClick"):
		show_text()

func start_dialogue(str_arr : Array) -> void:
	Signalbus.enable_escape.emit(false)
	hide_anim.play("enter")
	SceneManager.pause_everything()
	self.visible = true
	in_dialogue = false
	textbox.visible = false
	curr_index = 0
	curr_dialogue = str_arr
	cow_anim.play("enter")
	await cow_anim.animation_finished
	text_anim.play("popup")
	await text_anim.animation_finished
	
	show_text()
	
func show_text():
	label.text = ""
	in_dialogue = true
	if curr_index >= curr_dialogue.size():
		end_dialogue()
		return
	cow_anim.play("bounce")
	textbox.display_text(curr_dialogue[curr_index])
	curr_index += 1

func end_dialogue() -> void:
	Signalbus.enable_escape.emit(true)
	in_dialogue = false
	text_anim.play("fade")
	cow_anim.play("exit")
	await cow_anim.animation_finished
	self.visible = false
	SceneManager.unpause_everything()
