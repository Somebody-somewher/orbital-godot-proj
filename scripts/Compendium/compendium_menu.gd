extends Control
class_name CompendiumMenu

var open_state = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signalbus.connect("close_compendium", close_book)
	Signalbus.connect("open_compendium", open_book)

func open_book(search_id : String = "") -> void:
	if open_state:
		return

	Signalbus.pause_input.emit()
	if search_id != "":
		# id will always be valid (called by middle clicking cards)
		Signalbus.show_card_information.emit(search_id)
	AudioManager.play_sfx("page")
	$AnimationPlayer.play("enter_scene")
	open_state = true

func close_book() -> void:
	if !open_state:
		return
	$AnimationPlayer.play("exit_scene")
	open_state = false


func _on_texture_button_pressed() -> void:
	Signalbus.open_compendium.emit("")
