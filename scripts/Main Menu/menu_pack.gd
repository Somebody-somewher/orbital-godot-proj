extends CardPackBare
class_name MenuPack

@onready
var menu_logic : MenuLogic = get_tree().root.get_node("MainMenu/MenuLogic")

@onready
var card_manager = get_tree().root.get_node("MainMenu/CardManager")
@onready
var player_hand = get_tree().root.get_node("MainMenu/PlayerHand")
@onready
var mouse_tut = get_node("AnimatedSprite2D")
@onready
var animation = get_node("AnimationPlayer")

@onready var mouse_animation: AnimationPlayer = $AnimatedSprite2D/MouseFade
@onready var buttons: Control = $Buttons

func _ready() -> void:
	super._ready()
	enable_3d = true
	mouse_tut.play("default")
	mouse_animation.play("float")


func open_pack() -> void:
	self.get_node("Area2D/CollisionShape2D").disabled = true
	menu_logic.get_hand("main_menu")	
	self.dissolving = true
	mouse_animation.play("fade")
	destroy_pack()
