extends CardPackBare
class_name TutorialPack


@onready
var card_manager = get_tree().root.get_node("MainMenu/CardManager")
@onready
var player_hand = get_tree().root.get_node("MainMenu/PlayerHand")
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var mouse_animation: AnimationPlayer = $AnimatedSprite2D/MouseFade
@onready var buttons: Control = $Buttons

func _ready() -> void:
	super._ready()
	set_outline_color(Color.ORANGE)
	animated_sprite_2d.visible = false


func open_pack() -> void:
	self.get_node("Area2D/CollisionShape2D").disabled = true
	Signalbus.spawn_tut_hand.emit
	self.dissolving = true
	mouse_animation.play("fade")
	Signalbus.server_pack_choosing_end.emit()

func regenerate() -> void:
	is_chosen = false
	outline_pack(false)
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

func _on_cross_pressed() -> void:
	buttons.visible = false
