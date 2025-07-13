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

func _ready() -> void:
	super._ready()
	enable_3d = true
	mouse_tut.play("default")
	get_node("AnimatedSprite2D/MouseFade").play("float")


func open_pack() -> void:
	self.get_node("Area2D/CollisionShape2D").disabled = true
	menu_logic.get_hand("main_menu")	
	self.dissolving = true
	get_node("AnimatedSprite2D/MouseFade").play("fade")
	destroy_pack()
