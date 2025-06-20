@tool
extends EditorScript
#CTRL/CMD+SHIFT+X

func _run() -> void:
	print("TOOL RUNNING")
	var filenames := _build_file_list("res://", "tres", 20)
	for filename in filenames:
		var res: Resource = ResourceLoader.load(filename)
		ResourceSaver.save(res, res.resource_path)
	

static func _build_file_list(
	path: String, 
	suffix: String, 
	recursion_depth: int
) -> Array[String]:
	var dir = DirAccess.open(path)
	if not dir:
		push_error("An error occurred when trying to access path: %s" % [path])
		return []

	var files: Array[String]
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir() and recursion_depth:
			var sub_dir: String = "%s/%s" % [path, file_name]
			files.append_array(_build_file_list(sub_dir, suffix, recursion_depth - 1))
		elif file_name.ends_with(suffix):
			var full_path = "%s/%s" % [path, file_name]
			files.append(full_path)
		file_name = dir.get_next()

	return files
