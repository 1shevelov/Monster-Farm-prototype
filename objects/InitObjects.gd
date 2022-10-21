# initialises game objects
# and sends an array of objects' dictionaries to Spawner


extends GDScript

const HP := "hp"
const MONEY := "money"
const TYPE := "type"
const MIN := "min"
const MAX := "max"
const IMAGE := "image"

# values used to replace wrong ones
const MIN_VALUES := {
	HP: 1,
	MONEY: 0
}

const COIN := "Coin"
const ONEHITMOB := "OneHitMob"
const OBSTACLE := "Obstacle"

const OBJECTS_FILES := [
	"trimob.json",
	"big_stone.json",
	"treasure_chest.json"]
const OBJECTS: Array = []

const WEAPONS_FILE := "weapons.json"
var ALL_WEAPONS: Dictionary


func load_all_objects() -> void:
	for file in OBJECTS_FILES:
		OBJECTS.append(load_JSON(file))
	for each_obj in OBJECTS:
		validate_object(each_obj)
	ALL_WEAPONS = load_JSON(WEAPONS_FILE)

	
	Signals.emit_signal("objects_ready", OBJECTS)


func validate_object(obj: Dictionary) -> void:
	if obj.has(TYPE) and typeof(obj[TYPE]) == TYPE_STRING:
		match obj.type:
			COIN:
				validate_prop(obj, MONEY, true)
				validate_image(obj)
			OBSTACLE:
				validate_prop(obj, HP, true)
				validate_prop(obj, MONEY, false)
				validate_image(obj)
			ONEHITMOB:
				validate_prop(obj, MONEY, false)
				validate_image(obj)
			_:
				print("Object type unknown: ", obj)
	else:
		print("Obj has no \"type\" prop", obj)


# TODO
func validate_image(obj) -> void:
	if obj.has(IMAGE) and typeof(obj[IMAGE]) == TYPE_STRING:
		# load image
		# check size
		pass
	else:
		print("Wrong or absent %s prop in %s", [IMAGE, obj])


# if wrong or missed prop or value:
#	mandatory					- true		- false
#	------------------------------------------------------------
#	prop missed		 			- fix	 	- skip
#	prop has wrong type			- fix		- skip
#	wrong values or subprops	- fix		- fix
#		* fixing always by substituting with min value
func validate_prop(obj, prop: String, mandatory: bool) -> void:
	if obj.has(prop):
		match typeof(obj[prop]):
			TYPE_REAL:
				# should be >= MIN_VALUES
				if obj[prop] < MIN_VALUES[prop]:
					print("Wrong %s in %s", [prop, obj])
					obj[prop] = MIN_VALUES[prop]
			TYPE_DICTIONARY:
				# should have MIN and MAX properties of type number only
				# MIN >= MIN_VALUES & MAX >= MIN
				if not obj[prop].has(MIN) or typeof(obj[prop][MIN]) != TYPE_REAL \
				or obj[prop][MIN] < MIN_VALUES[prop]:
					print("Wrong %s.%s in %s", [prop, MIN, obj])
					obj[prop][MIN] = MIN_VALUES[prop]
				if not obj[prop].has(MAX) or typeof(obj[prop][MAX]) != TYPE_REAL \
				or obj[prop][MAX] < obj[prop][MIN]:
					print("Wrong %s.%s in %s", [prop, MAX, obj])
					obj[prop][MAX] = obj[prop][MIN]
			TYPE_ARRAY:
				# should have at least one value
				# values of type number only, each >= MIN_VALUES
				if obj[prop].length == 0:
					obj[prop] = MIN_VALUES[prop]
				for val in obj[prop]:
					if typeof(val) != TYPE_REAL or val < MIN_VALUES[prop]:
						val = MIN_VALUES[prop]
			_:
				print("Wrong type of %s in %s", [prop, obj])
				if mandatory:
					obj[prop] = MIN_VALUES[prop]
				else:
					# remove property of the wrong type if not mandatory
					obj.erase(prop)
	elif mandatory:
		print("No mandatory %s prop found in %s", [prop, obj])
		obj[prop] = MIN_VALUES[prop]


func load_JSON(object_file: String) -> Dictionary:
	var file: File = File.new()
	var full_file_name: String = Resources.objects + object_file
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
