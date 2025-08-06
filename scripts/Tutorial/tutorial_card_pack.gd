extends CardPackBare
class_name TutorialPack


@onready
var card_manager = get_tree().root.get_node("MainMenu/CardManager")
@onready
var player_hand = get_tree().root.get_node("MainMenu/PlayerHand")

@onready var mouse_animation: AnimationPlayer = $AnimatedSprite2D/MouseFade

func _ready() -> void:
	super._ready()
	enable_3d = true


func open_pack() -> void:
	self.get_node("Area2D/CollisionShape2D").disabled = true
	create_tut_card("apple")
	self.dissolving = true
	mouse_animation.play("fade")
	Signalbus.server_pack_choosing_end.emit()

func regenerate() -> void:
	self.get_node("Area2D/CollisionShape2D").disabled = false
	self.dissolving = false
	dissolve_value = 1
	get_node("AnimationPlayer").play("fall animation")
	sprite_ref.material.set_shader_parameter("dissolve_value", dissolve_value)

func create_tut_card(id_name) -> void:
	var instance = CardLoader.create_data_instance(id_name, -1)
	var player_uuid := PlayerManager.getCurrentPlayerUUID()
	instance.set_owner_uuid(player_uuid)
	var pos = position
	(CardLoader.card_mem as ServerCardMemory).add_card_in_hand(instance, player_uuid, pos)
