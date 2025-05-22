extends Node2D

func set_text(str : String) -> void:
	get_node("RichTextLabel").text = str

func show_text(on: bool) -> void:
	get_node("RichTextLabel").visible = on
