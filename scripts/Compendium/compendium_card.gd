extends Control
class_name CompendiumCard

var id_name : String = "obelisk"
var search_name : String

static var button_scene : PackedScene = preload("res://scenes/Compendium/compendium_card.tscn")

func _ready() -> void:
	var data = CardLoader.get_card_data(id_name)
	match data.category:
		CardData.CATEGORY.Sabotage:
			$CardBackButton.texture_normal = load("res://assets/card_sprites/sabo_card.png")
		CardData.CATEGORY.Power:
			$CardBackButton.texture_normal = load("res://assets/card_sprites/power_card.png")
		_:
			$CardBackButton.texture_normal = load("res://assets/card_sprites/blank_card.png")
	 
	$CardImage.texture = data.card_sprite
	search_name =  data.display_name
	$Label.text = data.display_name

static func new_button(id : String) -> CompendiumCard:
	var button = button_scene.instantiate()
	button.id_name = id
	return button

func _on_button_pressed() -> void:
	AudioManager.play_sfx("click")
	Signalbus.show_card_information.emit(id_name)
