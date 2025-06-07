extends Card
class_name MenuCard

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

#for constructor
static var menu_card_scene: PackedScene = load("res://scenes/Main Menu/menu_card.tscn")

var building : Building

# factory constructor
static func new_card(card_name : String) -> Card:
	var return_card : MenuCard = menu_card_scene.instantiate()
	var data : BuildingData = CardLoader.get_building_data(card_name) 
	var card_image_path = str("res://assets/card_sprites/blank_card.png")
	return_card.get_node("CardImage").texture = load(card_image_path)
	return_card.get_node("EntityImage").texture = data.card_sprite
	return_card.get_node("GhostImage").texture = data.card_sprite
	return_card.get_node("Texts/CardName").text = database_ref.get_card_name_by_id(card_name)
	return_card.id_name = card_name
	return return_card

# called when added to player hand
func initialize_card_effect() -> void:
	building = Building.new_building(id_name)
	building.visible = true
	building.get_node("Area2D/CollisionShape2D").disabled = true

# called when added to board
# fully replace card with effect, then free self instance
func swap_to_effect(scale_by: Vector2) -> void:
	self.get_node("Area2D/CollisionShape2D").disabled = true
	building.scale = scale_by
	building.visible = true
	building.get_node("Area2D/CollisionShape2D").disabled = false
	queue_free()
