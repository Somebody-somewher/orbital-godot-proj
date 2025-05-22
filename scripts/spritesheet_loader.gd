extends Node
class_name SpriteSheetLoader
# https://github.com/derkork/godot-resource-groups
# Temp solution until I can figure out something better

@export var sprite_grp : ResourceGroup

static var sprites_dict = {}
static var sprites : Array = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_grp.load_all_into(sprites)
	for s in sprites:
		sprites_dict.get_or_add(s.load_path.split("/")[-1].split(".")[0], s) 
	pass # Replace with function body.

static func get_sprite(id : String) -> CompressedTexture2D:
	print(sprites_dict)
	return sprites_dict.get(id)
