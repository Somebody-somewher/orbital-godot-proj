extends VBoxContainer

@onready var card_back: TextureRect = $BaseInfo/CardBack

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signalbus.connect("show_card_information", display_card)
	display_card("apple")

func display_card(id : String) -> void:
	var data : CardData = CardLoader.get_card_data(id)
	if data:
		match data.category:
			CardData.CATEGORY.Sabotage:
				card_back.texture = load("res://assets/card_sprites/sabo_card.png")
			CardData.CATEGORY.Power:
				card_back.texture = load("res://assets/card_sprites/power_card.png")
			_:
				card_back.texture = load("res://assets/card_sprites/blank_card.png")
		$BaseInfo/CardBack/CardImage.texture = data.card_sprite
		$BaseInfo/MarginContainer/VBoxContainer/HBoxContainer/CardName.text = data.display_name
		$BaseInfo/MarginContainer/VBoxContainer/Category.text = data.CATEGORY.keys()[data.category] + " Card"
		$BaseInfo/MarginContainer/VBoxContainer/Tags.text = tag_array_to_str(data.tags)
		$DescContainer/Description.text = data.desc
		$FlavourContainer/FlavorText.text = data.flavor

func tag_array_to_str(arr : Array[String]) -> String:
	var ret = ""
	var tag_no = arr.size()
	if tag_no == 0:
		return ret
	ret += arr[0]
		
	for i in range(tag_no - 1):
		ret += ", " + arr[i + 1] 
	return ret


func _on_close_button_pressed() -> void:
	AudioManager.play_sfx("click")
	Signalbus.close_compendium.emit()
