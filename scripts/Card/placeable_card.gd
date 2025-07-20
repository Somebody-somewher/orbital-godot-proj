extends PlayerHandCard
class_name PlaceableCard

static var placeable_card_script := preload("res://scripts/Card/placeable_card.gd")

static func new_card(cardinstance_data : CardInstanceData, cardimg_bg : Texture2D) -> PlaceableCard:
	var card := card_scene.instantiate()
	card.set_script(placeable_card_script)
	card.set_up(cardinstance_data, cardimg_bg)
	return card
	
func set_up(cardinstance_data : CardInstanceData, cardimg_bg : Texture2D) -> void:
	super.set_up(cardinstance_data, cardimg_bg)
	if cardinstance_data is BuildingInstanceData:
		if (cardinstance_data as BuildingInstanceData).foil:
			foiled = true
			self.material.set_shader_parameter("effect_alpha_mult",1)

# factory constructor
# TODO: pass the placeabale_data as the param instead?
#static func new_card(buildinginstance_data : BuildingInstanceData) -> Card:
	##var data = CardLoader.get_building_data(card_name)
	#var return_card : BuildingCard = CardLoader.building_card_scene.instantiate()
	#var card_image_path = str("res://assets/card_sprites/blank_card.png")
	#return_card.get_node("CardImage").texture = load(card_image_path)
	#return_card.get_node("EntityImage").texture = data.card_sprite
	#return_card.get_node("Texts/CardName").text = data.display_name
	#return_card.id_name = card_name
	#return return_card
	#
#static func new_card_by_data(building_data: BuildingInstanceData) -> Card:
	#var return_card : BuildingCard = CardLoader.building_card_scene.instantiate()
	#var card_image_path = str("res://assets/card_sprites/blank_card.png")
	#return_card.get_node("CardImage").texture = load(card_image_path)
	#return_card.get_node("EntityImage").texture = building_data.data.card_sprite
	#return_card.get_node("Texts/CardName").text = building_data.data.display_name
	#return_card.id_name = building_data.data.get_id()
	#return return_card

# called when added to player hand
#func initialize_card_effect() -> void:
	#building = Building.new_building(id_name)
	#building.visible = true
	#building.get_node("Area2D/CollisionShape2D").disabled = true
#
## called when added to board
## fully replace card with effect, then free self instance
#func swap_to_effect(scale_by: Vector2) -> void:
	#self.get_node("Area2D/CollisionShape2D").disabled = true
	#building.visible = true
	#building.get_node("Area2D/CollisionShape2D").disabled = false
	#queue_free()
