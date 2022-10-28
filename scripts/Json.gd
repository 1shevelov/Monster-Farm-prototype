extends Node

const MIN := "min"
const MAX := "max"

 
func validate_string(val) -> String:
	var MAXIMUM_LENGTH := 32
	
	if typeof(val) == TYPE_STRING \
	or typeof(val) == TYPE_REAL or typeof(val) == TYPE_INT:
		var temp_str := String(val)
		temp_str = temp_str.strip_escapes()
		temp_str = temp_str.strip_edges()
		return temp_str.left(MAXIMUM_LENGTH)
	else:
		print("Invalid type of %s = %s" % [val, typeof(val)])
		return ""


# val is a valid int and
#   min_val <= val <= max_val return val
# else return default_val
func validate_int(
	val,
	min_val: int,
	max_val: int,
	default_val: int,
	error_term: String
) -> int:
	
	match typeof(val):
		TYPE_INT:
			if val < min_val or val > max_val:
				print("Invalid %s value of \"%s\". Setting default" % [error_term, val])
				return default_val
			return val
		TYPE_REAL:
			if val < min_val or val > max_val:
				print("Invalid %s value of \"%s\". Setting default" % [error_term, val])
				return default_val
			return int(val)
		TYPE_STRING:
			if val.is_valid_float():
				var int_val: int = int(round(val.to_float()))
				if int_val < min_val or int_val > max_val:
					print("Invalid %s value of \"%s\". Setting default" % [error_term, int_val])
					return default_val
				return int_val
			else:
				print("Invalid %s value of \"%s\". Setting default" % [error_term, val])
				return default_val
		_:
			print("Invalid type of %s with value of \"%s\". Setting default" % [error_term, val])
			return default_val


# each arr member is a valid int and
# min_val <= arr[i] <= max_val
# else substitute a faulty val with default_val
# if empty, add one default_val
func validate_array_of_int(
	arr: Array,
	min_val: int,
	max_val: int,
	default_val: int,
	error_term: String
) -> void:
	var max_size := 100
	
	if arr.empty():
		print("%s array is empty, Setting one default value" % error_term)
		arr.append(default_val)
		return
	for i in arr.size():
		arr[i] = Json.validate_int(arr[i], min_val, max_val, \
		default_val, error_term)
		if i >= max_size:
			print("Too many values in %s. Array was truncated.", arr)
			break;


# val.min and val.max are valid ints and
#   min_val <= val.min <= val.max <= max_val
# else substitute faulty val with default_val
func validate_dic_of_int(
	dic: Dictionary,
	min_val: int,
	max_val: int,
	default_val: int,
	error_term: String
) -> void:
	if dic.has(MIN):
		dic[MIN] = Json.validate_int(dic[MIN], min_val, max_val, default_val, error_term)
	else:
		print("Invalid value of \"%s\" in %s. Setting it to default value" % [MIN, dic])
		dic[MIN] = default_val

	if dic.has(MAX):
		dic[MAX] = Json.validate_int(dic[MAX], min_val, max_val, default_val, error_term)
	else:
		print("Invalid value of \"%s\" in %s. Setting it to default value" % [MAX, dic])
		dic[MAX] = default_val
	if dic[MAX] < dic[MIN]:
		print("Invalid \"%s\" < \"%s\" in %s. Setting \"%s\" to \"%s\"" % [MAX, MIN, dic, MAX, MIN])
		dic[MAX] = dic[MIN]


# val is a valid float and
#   min_val < val <= max_val return val
# else return default_val
func validate_float(
	val,
	min_val: float,
	max_val: float,
	default_val: float,
	error_term: String
) -> float:
	
	match typeof(val):
		TYPE_REAL:
			if val <= min_val or val > max_val:
				print("Invalid %s value of \"%s\". Setting default" % [error_term, val])
				return default_val
			return val
		TYPE_STRING:
			if val.is_valid_float():
				var fl_val: float = val.to_float()
				if fl_val <= min_val or fl_val > max_val:
					print("Invalid %s value of \"%s\". Setting default" % [error_term, fl_val])
					return default_val
				return fl_val
			else:
				print("Invalid %s value of \"%s\". Setting default" % [error_term, val])
				return default_val
		_:
			print("Invalid type of %s with value of \"%s\". Setting default" % [error_term, val])
			return default_val


# val.min and val.max are valid floats and
#   min_val < val.min <= val.max <= max_val
# else substitute faulty val with default_val
func validate_dic_of_float(
	dic: Dictionary,
	min_val: float,
	max_val: float,
	default_val: float,
	error_term: String
) -> void:
	if dic.has(MIN):
		dic[MIN] = Json.validate_float(dic[MIN], min_val, max_val, default_val, error_term)
	else:
		print("Invalid value of \"%s\" in %s. Setting it to default value" % [MIN, dic])
		dic[MIN] = default_val

	if dic.has(MAX):
		dic[MAX] = Json.validate_float(dic[MAX], min_val, max_val, default_val, error_term)
	else:
		print("Invalid value of \"%s\" in %s. Setting it to default value" % [MAX, dic])
		dic[MAX] = default_val
	if dic[MAX] < dic[MIN]:
		print("Invalid \"%s\" < \"%s\" in %s. Setting \"%s\" to \"%s\"" % [MAX, MIN, dic, MAX, MIN])
		dic[MAX] = dic[MIN]


func load_file(object_file: String) -> Dictionary:
	var file: File = File.new()
	var err: int = file.open(object_file, File.READ)
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
		print_debug("Invalid JSON data, error: " % str_err)
		file.close()
		return {}
	var data: Dictionary = parse_json(json_string)
	file.close()
	return data


