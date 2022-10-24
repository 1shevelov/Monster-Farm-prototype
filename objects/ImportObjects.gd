# initialises game objects
# and sends an array of objects' dictionaries to Spawner


extends GDScript

const HP := "hp"
const MONEY := "money"
const TYPE := "type"
const MIN := "min"
const MAX := "max"
const IMAGE := "image"
const WEAPON := "weapon"

# values used to replace wrong ones
const MIN_VALUES := {
	HP: 1,
	MONEY: 0
}

const COIN := "Coin"
const ONEHITMOB := "OneHitMob"
const OBSTACLE := "Obstacle"

const ASSETS_DIR := "res://assets/objects/"
const SCENES_DIR := "res://objects/"

const AVATAR_FILE := "avatar.json"
var avatar_obj: Dictionary

const OBJECTS_FILES := [
	"trimob.json",
	"big_stone.json",
	"treasure_chest.json"]
const OBJECTS: Array = []

const WEAPONS_FILE := "weapons.json"
var weapons: Array = []
const WEAPON_SCENE := SCENES_DIR + "Weapon.tscn"
var weapon_scene: PackedScene #= preload(WEAPON_SCENE)
var weapon_instance
const NAME = "name"



func get_avatar() -> Dictionary:
	return avatar_obj


func load_all_objects() -> void:
	load_and_validate_weapons()
	
	for file in OBJECTS_FILES:
		OBJECTS.append(load_JSON(file))
	for each_obj in OBJECTS:
		validate_object(each_obj)
	
	load_and_validate_avatar()

	
	Signals.emit_signal("objects_ready", OBJECTS)


func load_and_validate_weapons() -> void:
	var weapons_obj: Dictionary = load_JSON(WEAPONS_FILE)
	if weapons_obj.empty():
		print("No weapons")
		return
	weapon_scene = load(WEAPON_SCENE)
	weapons = weapons_obj.values()
	for w in weapons.size():
		weapon_instance = weapon_scene.instance()
		if not weapon_instance.init(weapons[w]):
			print("Weapon \"%s\" had errors. Skipped" % weapons[w][NAME])
			weapons[w].clear()
#		else:
#			print("Weapon \"%s\" is OK" % weapons[w][NAME])
		weapon_instance.queue_free()


func load_and_validate_avatar() -> void:
	avatar_obj = load_JSON(AVATAR_FILE)
	validate_num_prop(avatar_obj, HP, true)
	validate_num_prop(avatar_obj, MONEY, false)
	# can avatar start with no weapon (0 damage)? how to handle one-hit-mobs?
	validate_string_prop(avatar_obj, WEAPON, false)


func validate_object(obj: Dictionary) -> void:
	if obj.has(TYPE) and typeof(obj[TYPE]) == TYPE_STRING:
		match obj.type:
			COIN:
				validate_num_prop(obj, MONEY, true)
				validate_image(obj)
			OBSTACLE:
				validate_num_prop(obj, HP, true)
				validate_num_prop(obj, MONEY, false)
				validate_image(obj)
				validate_string_prop(obj, WEAPON, false)
			ONEHITMOB:
				validate_num_prop(obj, MONEY, false)
				validate_image(obj)
				validate_string_prop(obj, WEAPON, false)
			_:
				print("Object type unknown: ", obj)
	else:
		print("Obj has no \"type\" prop ", obj)


# TODO: allow "weapon" prop to have a 
# String value - look for weapon dic in weapons array and write weapon dic in the obj
# Dictionary value - validate obj
func validate_string_prop(obj: Dictionary, prop: String, mandatory: bool) -> void:
	if obj.has(prop) and typeof(obj[prop]) == TYPE_STRING:
		match prop:
			WEAPON:
				var set := false
				for w in weapons:
					if w.name == obj[WEAPON]:
						obj[WEAPON] = w
						set = true
						break;
				if not set:
					obj[WEAPON] = weapons[0]
					print("ERROR in weapon of ", obj)
					print("Weapon %s was used" % weapons[0].name)
	elif mandatory:
		print("ERROR: No mandatory %s prop found in %s" % [prop, obj])


# TODO
func validate_image(obj) -> void:
	if obj.has(IMAGE) and typeof(obj[IMAGE]) == TYPE_STRING:
		# set full image path for loading
		obj[IMAGE] = ASSETS_DIR + obj[IMAGE]
		# load image
		# check size
		pass
	else:
		print("Wrong or absent %s prop in %s" % [IMAGE, obj])


# if wrong or missed prop or value:
#	mandatory					- true		- false
#	------------------------------------------------------------
#	prop missed		 			- fix	 	- skip
#	prop has wrong type			- fix		- skip
#	wrong values or subprops	- fix		- fix
#		* fixing always by substituting with min value
func validate_num_prop(obj, prop: String, mandatory: bool) -> void:
	if obj.has(prop):
		match typeof(obj[prop]):
			TYPE_REAL:
				# should be >= MIN_VALUES
				if obj[prop] < MIN_VALUES[prop]:
					print("Wrong %s in %s" % [prop, obj])
					obj[prop] = MIN_VALUES[prop]
			TYPE_DICTIONARY:
				# should have MIN and MAX properties of type number only
				# MIN >= MIN_VALUES & MAX >= MIN
				if not obj[prop].has(MIN) or typeof(obj[prop][MIN]) != TYPE_REAL \
				or obj[prop][MIN] < MIN_VALUES[prop]:
					print("Wrong %s.%s in %s" % [prop, MIN, obj])
					obj[prop][MIN] = MIN_VALUES[prop]
				if not obj[prop].has(MAX) or typeof(obj[prop][MAX]) != TYPE_REAL \
				or obj[prop][MAX] < obj[prop][MIN]:
					print("Wrong %s.%s in %s" % [prop, MAX, obj])
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
				print("Wrong type of %s in %s" % [prop, obj])
				if mandatory:
					obj[prop] = MIN_VALUES[prop]
				else:
					# remove property of the wrong type if not mandatory
					obj.erase(prop)
	elif mandatory:
		print("No mandatory %s prop found in %s" % [prop, obj])
		obj[prop] = MIN_VALUES[prop]


# TODO: move this method to json class
func load_JSON(object_file: String) -> Dictionary:
	var file: File = File.new()
	var full_file_name: String = ASSETS_DIR + object_file
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
		print_debug("Invalid JSON data, error: " % str_err)
		file.close()
		return {}
	var data: Dictionary = parse_json(json_string)
	file.close()
	return data
