extends Node

const MIN := "min"
const MAX := "max"

 
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

