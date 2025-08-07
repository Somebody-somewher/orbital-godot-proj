extends Control
class_name TutorialOverlay

@onready var text_anim: AnimationPlayer = $TextAnim
@onready var cow_anim: AnimationPlayer = $CowAnim
@onready var hide_anim: AnimationPlayer = $HideAnim

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
		if Input.is_action_just_pressed("escape"):
			start_dialogue(["reeaaelelllt longreeaaelelllt longreeaaelelllt longreeaaelelllt longreeaaelelllt long 1","2","3","reeaaelelllt longreeaaelelllt longreeaaelelllt long14","5","6","7","8","9","0","1"])
		return
	if Input.is_action_just_pressed("leftMouseClick"):
		show_text()

func start_dialogue(str_arr : Array[String]) -> void:
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
	in_dialogue = true
	if curr_index >= curr_dialogue.size():
		end_dialogue()
		return
	textbox.display_text(curr_dialogue[curr_index])
	curr_index += 1

func end_dialogue() -> void:
	in_dialogue = false
	text_anim.play("fade")
	cow_anim.play("exit")
	await cow_anim.animation_finished
	self.visible = false
	SceneManager.unpause_everything()
