extends Node

const files_prefix := "res://objects/"
const mobs_files := ["treasure_chest.json"]
const mobs: Array = []


func _ready() -> void:
	for i in mobs_files.size():
		mobs.append(load_mob(mobs_files[i]))
		print(mobs[i])
	

func load_mob(mob_file: String) -> Dictionary:
	var file: File = File.new()
	var full_file_name: String = files_prefix + mob_file
	var err: int = file.open(full_file_name, File.READ)
	if err == 7: # file not found
		file.close()
		return {}
	elif err != 0:
		print_debug("Error while trying to load \"%s\".\nError message: %s" \
			% [mob_file, err])
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
