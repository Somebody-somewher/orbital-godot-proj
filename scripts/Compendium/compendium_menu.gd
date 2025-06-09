extends Control
class_name CompendiumMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signalbus.connect("close_compendium", close_book)
	Signalbus.connect("open_compendium", open_book)

func open_book(search_id : String = "") -> void:
	if search_id != "":
		# id will always be valid (called by middle clicking cards)
		Signalbus.show_card_information.emit(search_id)
	$AnimationPlayer.play("enter_scene")

func close_book() -> void:
	$AnimationPlayer.play("exit_scene")


func _on_texture_button_pressed() -> void:
	Signalbus.open_compendium.emit("")
