extends Card
class_name BuildingCard

#for constructor
static var building_card_scene: PackedScene = load("res://scenes/Card/building_card.tscn")

var building : Building

# factory constructor
static func new_card(card_name : String) -> Card:
	var return_card : BuildingCard = building_card_scene.instantiate()
	var card_image_path = str("res://assets/card_sprites/blank_card.png")
	var entity_image_path = str("res://assets/entity_sprites/"+ card_name + ".png")
	return_card.get_node("CardImage").texture = load(card_image_path)
	return_card.get_node("EntityImage").texture = load(entity_image_path)
	return_card.get_node("GhostImage").texture = load(entity_image_path)
	return_card.get_node("Texts/CardName").text = CardLoader.get_display_name(card_name)
	return_card.id_name = card_name
	return return_card

# called when added to player hand
func initialize_card_effect() -> void:
	building = Building.new_building(id_name)
	building.data = CardLoader.get_building_data(id_name)
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
