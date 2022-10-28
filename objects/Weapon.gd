extends Node2D

# MANDATORY properties

# 0 < name.length < NAME_MAXIMUM_LENGTH 
const NAME := "name"
const NAME_MAXIMUM_LENGTH := 32

# DAMAGE_DEFAULT <= damage <= DAMAGE_MAXIMUM
const DAMAGE := "damage"
const DAMAGE_DEFAULT := 1
const DAMAGE_MAXIMUM := 1000000


# OPTIONAL properties

# if damage is of type object
# 0 <= damage_min <= damage_max <= DAMAGE_MAXIMUM
const DAMAGE_MIN := "min"
const DAMAGE_MAX := "max"

# if missed, the weapon is considered one-time
# 0.0 < delay <= DELAY_MAX, in seconds
const DELAY := "delay"
const DELAY_MAXIMUM := 100.0
const DELAY_DEFAULT := 1.0

# if true or "1" delay is ignored
# true, false, "1" or "0"
const ONE_TIME := "one-time"

# probability of making damage
# 0.0 < probability <= 1.0
const PROBABILITY := "probability"
const PROBABILITY_DEFAULT := 1.0

# for UI
#const IMAGE := "image"

var weapon_name := ""
var damage_min := 0
var damage_max := 0
var damage_array := []
var probability := PROBABILITY_DEFAULT
var delay := DELAY_DEFAULT
var one_time := false
#var description := ""
#var damage_type = one of DAMAGE_TYPES enum
#var ui_picture = $Picture


func init(from_json: Dictionary) -> bool:
	if from_json.has(NAME):
		weapon_name = Json.validate_string(from_json[NAME])
	if from_json.has(DAMAGE):
		if typeof(from_json[DAMAGE]) == TYPE_DICTIONARY:
			Json.validate_dic_of_int(from_json[DAMAGE], \
			DAMAGE_DEFAULT, DAMAGE_MAXIMUM, DAMAGE_DEFAULT, DAMAGE)
			damage_min = from_json[DAMAGE][DAMAGE_MIN]
			damage_max = from_json[DAMAGE][DAMAGE_MAX]
		elif typeof(from_json[DAMAGE]) == TYPE_ARRAY:
			Json.validate_array_of_int(from_json[DAMAGE], \
			DAMAGE_DEFAULT, DAMAGE_MAXIMUM, DAMAGE_DEFAULT, DAMAGE)
			damage_array = from_json[DAMAGE]
		else:
			damage_min = Json.validate_int(from_json[DAMAGE], \
			DAMAGE_DEFAULT, DAMAGE_MAXIMUM, DAMAGE_DEFAULT, DAMAGE)
			damage_max = damage_min
	else:
		print("Missed mandatory %s value in weapon %s" % [DAMAGE, from_json[NAME]])
		return false
	
	if from_json.has(PROBABILITY):
		probability = Json.validate_float(from_json[PROBABILITY], 0.0, 1.0, \
		PROBABILITY_DEFAULT, PROBABILITY)
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
		delay = Json.validate_float(from_json[DELAY], 0.0, DELAY_MAXIMUM, DELAY_DEFAULT, DELAY)
	elif not one_time:
		print("%s value missed in wepon %s. Using default value." % [DELAY, from_json[NAME]])
				
	return true
	
	
func get_damage() -> int:
#	randi() % 100 + 1 # Returns random integer between 1 and 100
# % 10 + 5
	if not damage_array.empty():
		# random member of array returned
		return damage_array[randi() % damage_array.size()]
		# or a next (need number variable)
	if randf() < probability:
		return randi() % (damage_max - damage_min + 1) + damage_min
	else:
		return 0


func get_delay() -> float:
	return delay


func is_one_time() -> bool:
	return one_time


# TODO: test damage formula, wepon json validation
