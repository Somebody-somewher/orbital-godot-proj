@tool
extends EditorScript
#CTRL/CMD+SHIFT+X

func _run():
	print("Updating Resources")
	var dir := DirAccess.open("res://Resources/CardSetData/")
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var path = "res://Resources/CardSetData/" + file_name
			print(path)
			var res = ResourceLoader.load(path)
			res.set_script(load("res://scripts/Card/cardset_data.gd"))
			ResourceSaver.save(res, path)
		file_name = dir.get_next()
	dir.list_dir_end()
