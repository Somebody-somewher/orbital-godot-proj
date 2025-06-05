extends Resource
class_name AudioData

@export var group_name : String

@export_category("Audio Array")
@export var variations : Array[AudioStream]

@export var default : Callable = get_first

func get_default() -> AudioStream:
	return default.call()

func get_first() -> AudioStream:
	return variations[0]

func get_random() -> AudioStream:
	return variations.pick_random()
