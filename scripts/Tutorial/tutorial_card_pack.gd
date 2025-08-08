extends CardPackBare
class_name TutorialPack

@onready
var card_manager = get_tree().root.get_node("MainMenu/CardManager")
@onready
var player_hand = get_tree().root.get_node("MainMenu/PlayerHand")
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var mouse_animation: AnimationPlayer = $AnimatedSprite2D/MouseFade
@onready var buttons: Control = $Buttons

var cards = []

func _ready() -> void:
	super._ready()
	set_outline_color(Color.ORANGE)
	animated_sprite_2d.visible = false


func open_pack() -> void:
	self.get_node("Area2D/CollisionShape2D").disabled = true
	self.dissolving = true
	
	for card in cards:
		create_tut_card(card)
	
	mouse_animation.play("fade")
	Signalbus.server_pack_choosing_end.emit()

func regenerate() -> void:
	position = Vector2(1086, 450)
	is_chosen = false
	outline_pack(false)
	buttons.visible = false
	self.get_node("Area2D/CollisionShape2D").disabled = false
	self.dissolving = false
	dissolve_value = 1
	get_node("AnimationPlayer").play("fall animation")
	sprite_ref.material.set_shader_parameter("dissolve_value", dissolve_value)

func choose_or_open() -> bool:
	if is_chosen:
		open_pack()
		return false
	else:
		select_pack()
	return false

func select_pack() -> void:
	buttons.visible = true

func _on_check_pressed() -> void:
	outline_pack(true)
	buttons.visible = false
	is_chosen = true
	Signalbus.tut_pack_selected.emit()

func _on_cross_pressed() -> void:
	buttons.visible = false

func create_tut_card(id_name) -> void:
	var instance = CardLoader.create_data_instance(id_name, -1)
	var player_uuid := PlayerManager.getCurrentPlayerUUID()
	instance.set_owner_uuid(player_uuid)
	var pos = self.position
	(CardLoader.card_mem as ServerCardMemory).add_card_in_hand(instance, player_uuid, pos)
