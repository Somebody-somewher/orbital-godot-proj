extends Resource
class_name SpriteHandler
# For abstracting away how we deal with sprites in future
# We probably need to change to using a spritesheet later 

@export var sprites : Dictionary[String, Texture2D]


# GDScript no overloading :<
func get_sprite_by_data(data : Array) -> Texture2D:
	return sprites[data[0]]

func get_sprite(sprite_id : String) -> Texture2D:
	return sprites[sprite_id]
