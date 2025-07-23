extends Node2D

@export var layer1 : Array[Texture2D]
@export var layer2 : Array[Texture2D]
@export var layer3 : Array[Texture2D]
@export var layer4 : Array[Texture2D]

var rng = RandomNumberGenerator.new()

@onready var sprite_1: Sprite2D = $ParallaxBackground/ParallaxLayer/Sprite2D
@onready var sprite_2: Sprite2D = $ParallaxBackground/ParallaxLayer2/Sprite2D
@onready var sprite_3: Sprite2D = $ParallaxBackground/ParallaxLayer3/Sprite2D
@onready var sprite_4: Sprite2D = $ParallaxBackground/ParallaxLayer4/Sprite2D

func _ready() -> void:
	var index = rng.randi()%3
	sprite_1.texture = layer1[index]
	sprite_2.texture = layer2[index]
	sprite_3.texture = layer3[index]
	sprite_4.texture = layer4[index]
