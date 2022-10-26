extends Node2D

# MANDATORY properties

# 0 < name.length < NAME_MAXIMUM_LENGTH 
const NAME := "name"
const NAME_MAXIMUM_LENGTH := 32

# 0 <= damage <= DAMAGE_MAXIMUM
const DAMAGE := "damage"
const DAMAGE_MAXIMUM := 1000000


# OPTIONAL properties

# if damage is of type object
# 0 <= damage_min <= damage_max <= DAMAGE_MAXIMUM
const DAMAGE_MIN := "min"
const DAMAGE_MAX := "max"

# if damage is of type array
const DAMAGE_MAXIMUM_VALUES := 100

# if missed, the weapon is considered one-time
# 0.0 < delay <= DELAY_MAX, in seconds
const DELAY := "delay"
const DELAY_MAXIMUM := 100.0

# if true or "1" delay is ignored
# true, false, "1" or "0"
const ONE_TIME := "one-time"

# probability of making damage
# 0.0 < probability <= 1.0
const PROBABILITY := "probability"

# for UI
#const IMAGE := "image"

var weapon_name := ""
var damage_min := 0
var damage_max := 0
var damage_array := []
var probability := 1.0
var delay := 1.0
var one_time := false
#var description := ""
#var damage_type = one of DAMAGE_TYPES enum
#var ui_picture = $Picture


func init(from_json: Dictionary) -> bool:
	if from_json.has(NAME) and \
	(typeof(from_json[NAME]) == TYPE_STRING or typeof(from_json[NAME]) == TYPE_REAL):
		var temp_str: String = String(from_json.name)
		temp_str = temp_str.strip_escapes()
		temp_str = temp_str.strip_edges()
		weapon_name = temp_str.left(NAME_MAXIMUM_LENGTH)
	else:
		print("Invalid weapon %s in %s" % [NAME, from_json])
		return false
	
	if from_json.has(DAMAGE):
		match typeof(from_json[DAMAGE]):
			TYPE_REAL, TYPE_STRING:
				var validation_res :=  \
				Json.validate_int(from_json[DAMAGE], 0, DAMAGE_MAXIMUM, DAMAGE)
				if validation_res == -1:
					return false
				damage_min = validation_res
				damage_max = damage_min
			TYPE_DICTIONARY:
				if from_json[DAMAGE].has(DAMAGE_MIN):
					var validation_res :=  \
					Json.validate_int(from_json[DAMAGE][DAMAGE_MIN], 0, DAMAGE_MAXIMUM, DAMAGE)
					if validation_res == -1:
						return false
					damage_min = validation_res
				if from_json[DAMAGE].has(DAMAGE_MAX):
					var validation_res :=  \
					Json.validate_int(from_json[DAMAGE][DAMAGE_MAX], 0, DAMAGE_MAXIMUM, DAMAGE)
					if validation_res == -1:
						return false
					damage_max = validation_res
				if damage_max < damage_min:
					print("Error: %s < %s in weapon %s" % [damage_max, damage_min, from_json[NAME]])
					return false
			TYPE_ARRAY:
				if from_json[DAMAGE].empty():
					print("Wrong value of %s in weapon %s" % [DAMAGE, from_json[NAME]])
					return false
				var validation_res: int
				for val in from_json[DAMAGE]:
					validation_res = Json.validate_int(val, 0, DAMAGE_MAXIMUM, DAMAGE)
					if validation_res == -1:
						print("Invalid %s value in weapon %s" % [DAMAGE, from_json[NAME]])
					else:
						damage_array.append(validation_res)
						if damage_array.size() >= DAMAGE_MAXIMUM_VALUES:
							print("Too many %s values in weapon %s. Array was truncated.", \
							[DAMAGE, from_json[NAME]])
							break;
				if damage_array.empty():
					print("No valid %s values in weapon %s" % [DAMAGE, from_json[NAME]])
					return false
			_:
				print("Invalid type of %s in weapon %s" % [DAMAGE, from_json[NAME]])
				return false
	else:
		print("Missed mandatory %s value in weapon %s" % [DAMAGE, from_json[NAME]])
		return false
	
	if from_json.has(PROBABILITY):
		if typeof(from_json[PROBABILITY]) == TYPE_REAL \
		or typeof(from_json[PROBABILITY]) == TYPE_STRING:
				var validation_res :=  \
				Json.validate_float(from_json[PROBABILITY], 0.0, 1.0, PROBABILITY)
				if validation_res == -1.0:
					return false
				probability = validation_res
		else:
			print("Wrong type of %s value in weapon %s. Using default value." \
			% [PROBABILITY, from_json[NAME]])
	else:
		print("%s value missed in weapon %s. Using default value." % [PROBABILITY, from_json[NAME]])
			
	if from_json.has(ONE_TIME):
		if typeof(ONE_TIME) == TYPE_BOOL:
			one_time = from_json[ONE_TIME]
		elif typeof(ONE_TIME) == TYPE_REAL or typeof(ONE_TIME) == TYPE_STRING:
			one_time = bool(from_json[ONE_TIME])
		else:
			print("Wrong type of %s in weapon %s" % [ONE_TIME, from_json[NAME]])
			
	if from_json.has(DELAY):
		if typeof(from_json[DELAY]) == TYPE_REAL \
		or typeof(from_json[DELAY]) == TYPE_STRING:
				var validation_res :=  \
				Json.validate_float(from_json[DELAY], 0.0, DELAY_MAXIMUM, DELAY)
				if validation_res == -1.0:
					return false
				delay = validation_res
		else:
			print("Wrong type of %s value in weapon %s. Using default value." \
			% [DELAY, from_json[NAME]])
	elif not one_time:
		print("%s value missed in wepon %s. Using default value." % [DELAY, from_json[NAME]])
				
	return true
	
	
func get_damage() -> int:
#	randi() % 100 + 1 # Returns random integer between 1 and 100
# % 10 + 5
	if not damage_array.empty():
		return damage_array[randi() % damage_array.size()]
	if randf() < probability:
		return randi() % (damage_max - damage_min + 1) + damage_min
	else:
		return 0


func get_delay() -> float:
	return delay


func is_one_time() -> bool:
	return one_time


# TODO: test damage formula, wepon json validation
