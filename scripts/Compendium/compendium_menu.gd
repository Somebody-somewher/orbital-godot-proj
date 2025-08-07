extends Control
class_name CompendiumMenu

var open_state = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signalbus.connect("close_compendium", close_book)
	Signalbus.connect("open_compendium", open_book)

func open_book(search_id : String = "") -> void:
	if open_state or SceneManager.is_everything_paused:
		return

	Signalbus.pause_input.emit()
	Signalbus.enable_escape.emit(false)
	if search_id != "":
		# id will always be valid (called by middle clicking cards)
		Signalbus.show_card_information.emit(search_id)
	AudioManager.play_sfx("page")
	$AnimationPlayer.play("enter_scene")
	open_state = true

func close_book() -> void:
	if !open_state:
		return
	Signalbus.tut_close_compendium.emit()
	$AnimationPlayer.play("exit_scene")
	open_state = false
	await get_tree().create_timer(.1).timeout
	Signalbus.enable_escape.emit(true)


func _on_texture_button_pressed() -> void:
	Signalbus.open_compendium.emit("")
