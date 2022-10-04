extends GDScript

const files_prefix := "res://objects/"
const objects_files := ["treasure_chest.json"]
const objects: Array = []


func _ready() -> void:
	pass
	

func load_all_objects() -> void:
	for i in objects_files.size():
		objects.append(load_object(objects_files[i]))
		if not validate_object(objects[i]):
			objects.pop_back()
		else:
			build_object(objects[i])


func validate_object(_object: Dictionary) -> bool:
#	for each type of object validate the presence of the necessary properties
#	and values
#		print(object)
	return true


func build_object(_object: Dictionary) -> void:
#	make scene
	pass


func load_object(object_file: String) -> Dictionary:
	var file: File = File.new()
	var full_file_name: String = files_prefix + object_file
	var err: int = file.open(full_file_name, File.READ)
	if err == 7: # file not found
		file.close()
		return {}
	elif err != 0:
		print_debug("Error while trying to load \"%s\".\nError message: %s" \
			% [object_file, err])
		# TODO: GlobalScope.Error.keys()[err])
		file.close()
		return {}
	var json_string: String = file.get_as_text()
	var str_err: String = validate_json(json_string)
	if str_err:
		print_debug("Invalid JSON data loading settings, error: ", str_err)
		file.close()
		return {}
	var data: Dictionary = parse_json(json_string)
	file.close()
	return data
