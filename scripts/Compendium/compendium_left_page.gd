extends VBoxContainer

var items : Array[CompendiumCard] = []
var matches : Array[CompendiumCard] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for b_data in CardLoader.buildings:
		if b_data and !b_data.hidden:
			var new_child = CompendiumCard.new_button(b_data.id_name)
			$ScrollContainer/GridContainer.add_child(new_child)
			items.append(new_child)
		

func _on_search_bar_text_changed(new_text: String) -> void:
	if new_text == "":
		for i in items:
			i.show()
		return
	for i in items:
		if new_text.to_upper() in i.search_name.to_upper():
			i.show()
		else:
			i.hide()
