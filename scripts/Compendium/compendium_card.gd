extends Control
class_name CompendiumCard

var id_name : String = "obelisk"
var temp_click_count := 0

var search_name : String
var tags : Array[String]

@export var debug_click_spawn := 7

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
	tags = data.tags

static func new_button(id : String) -> CompendiumCard:
	var button = button_scene.instantiate()
	button.id_name = id
	return button

func _on_button_pressed() -> void:
	AudioManager.play_sfx("click")
	Signalbus.show_card_information.emit(id_name)
	temp_click_count += 1
	if temp_click_count == 1 and multiplayer.is_server():
		get_tree().create_timer(1.0).timeout.connect(
			func(): debug_create_card(id_name)
		) 

func in_tags(str : String) -> bool:
	for tag in tags:
		if str in tag:
			return true
	return false

func debug_create_card(id_name) -> void:
	if temp_click_count >= debug_click_spawn:
		var instance = CardLoader.create_data_instance(id_name, -1)
		var player_uuid := PlayerManager.getCurrentPlayerUUID()
		instance.set_owner_uuid(player_uuid)
		var pos = Vector2((0 + 0.5) * 113, (0 + 0.5) * 113)
		(CardLoader.card_mem as ServerCardMemory).add_card_in_hand(instance, player_uuid, pos)
	temp_click_count = 0
