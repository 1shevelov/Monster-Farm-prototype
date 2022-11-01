extends Node2D

# only for the owner of the weapon
signal weapon_attacked

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
const DELAY_MINIMUM := 0.05
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


func connect_attack_signal() -> bool:
	if one_time:
		var err = connect("weapon_attacked", get_parent(), "on_weapon_attacked", \
		[], CONNECT_DEFERRED + CONNECT_ONESHOT)
		if err != OK:
			print_debug("Error connecting \"weapon_attacked\" with its parent ", get_parent())
			return false
	else:
		var err = connect("weapon_attacked", get_parent(), "on_weapon_attacked", \
		[], CONNECT_DEFERRED)
		if err != OK:
			print_debug("Error connecting \"weapon_attacked\" with its parent ", get_parent())
			return false
	return true


func init_component(from_json: Dictionary) -> bool:
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
		delay = Json.validate_float(from_json[DELAY], \
		DELAY_MINIMUM, DELAY_MAXIMUM, DELAY_DEFAULT, DELAY)
	elif not one_time:
		print("%s value missed in wepon %s. Using default value." % [DELAY, from_json[NAME]])
	if not one_time:
		$AttackTimer.set_wait_time(delay)
				
	if not connect_attack_signal():
		return false
	return true
	
	
func get_damage() -> int:
	if not damage_array.empty():
		# random member of array returned
		return damage_array[randi() % damage_array.size()]
		# or a next (need number variable)
	if randf() < probability:
		return randi() % (damage_max - damage_min + 1) + damage_min
	else:
		return 0


func attack_start() -> void:
	if not one_time:
		$AttackTimer.start()


#func is_one_time() -> bool:
#	return one_time


func _on_AttackTimer_timeout() -> void:
	emit_signal("weapon_attacked", get_damage())


func attack_stop() -> void:
	if one_time:
		emit_signal("weapon_attacked", get_damage())
	else:
		$AttackTimer.stop()


