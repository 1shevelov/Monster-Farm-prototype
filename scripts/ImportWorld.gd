# initialises game objects


extends Node

const HP := "hp"
const MONEY := "money"
const TYPE := "type"
const MIN := "min"
const MAX := "max"
const IMAGE := "image"
const WEAPON := "weapon"

# values used to replace wrong ones
#const MIN_VALUES := {
#	HP: 1,
#	MONEY: 0
#}

const COIN := "Coin"
const ONEHITMOB := "OneHitMob"
const OBSTACLE := "Obstacle"

const OBJECTS_RES_DIR := "res://assets/objects/"
const SCENES_DIR := "res://objects/"

const AVATAR_FILE := "avatar.json"
#var avatar_obj: Dictionary

const OBJECTS_FILES := [
	"trimob.json",
	"big_stone.json",
	"treasure_chest.json"]
const OBJECTS: Array = []

const WEAPONS_FILE := "weapons.json"
var weapons: Array = []
const WEAPON_SCENE := SCENES_DIR + "Weapon.tscn"
onready var weapon_scene: PackedScene = preload(WEAPON_SCENE)
var weapon_instance
const NAME = "name"



#func get_avatar() -> Dictionary:
#	return avatar_obj


func load_all_objects() -> Array:
	load_and_validate_weapons()
	
	for file in OBJECTS_FILES:
		OBJECTS.append(Json.load_file(OBJECTS_RES_DIR + file))
	for each_obj in OBJECTS:
		validate_object(each_obj)
	
	return OBJECTS


func load_and_validate_weapons() -> void:
	var weapons_obj: Dictionary = Json.load_file(OBJECTS_RES_DIR + WEAPONS_FILE)
	if weapons_obj.empty():
		print("No weapons")
		return
#	weapon_scene = load(WEAPON_SCENE)
	weapons = weapons_obj.values()
	for w in weapons.size():
		weapon_instance = weapon_scene.instance()
		add_child(weapon_instance)
		if not weapon_instance.init_component(weapons[w]):
			print("Weapon \"%s\" had errors. Skipped" % weapons[w][NAME])
			weapons[w].clear()
#		else:
#			print("Weapon \"%s\" is OK" % weapons[w][NAME])
		weapon_instance.queue_free()
		
#	print_debug(weapons)


func load_avatar() -> Dictionary:
	var avatar_obj = Json.load_file(OBJECTS_RES_DIR + AVATAR_FILE)
	insert_weapon(avatar_obj, true)
	return avatar_obj


func validate_object(obj: Dictionary) -> void:
	if obj.has(TYPE):
		obj[TYPE] = Json.validate_string(obj[TYPE])
		match obj[TYPE]:
			COIN:
#				validate_num_prop(obj, MONEY, true)
				validate_image(obj)
			OBSTACLE:
#				validate_num_prop(obj, HP, true)
#				validate_num_prop(obj, MONEY, false)
				validate_image(obj)
				insert_weapon(obj, false)
			ONEHITMOB:
#				validate_num_prop(obj, MONEY, false)
				validate_image(obj)
				insert_weapon(obj, false)
			_:
				print("Object type unknown: ", obj)
	else:
		print("Obj has no \"type\" prop ", obj)


# String value - look for weapon dic in weapons array and write weapon dic in the obj
# Dictionary value - validate obj
func insert_weapon(obj: Dictionary, mandatory: bool) -> void:
	if obj.has(WEAPON):
		obj[WEAPON] = Json.validate_string(obj[WEAPON])
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
		obj[WEAPON] = weapons[0]
		print("ERROR no weapon found in ", obj)
		print("Weapon %s was used" % weapons[0].name)


# TODO
func validate_image(obj) -> void:
	if obj.has(IMAGE) and typeof(obj[IMAGE]) == TYPE_STRING:
		# set full image path for loading
		obj[IMAGE] = OBJECTS_RES_DIR + obj[IMAGE]
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
#func validate_num_prop(obj: Dictionary, prop: String, mandatory: bool) -> void:
#	if obj.has(prop):
#		match typeof(obj[prop]):
#			TYPE_DICTIONARY:
#				# should have MIN and MAX properties of type number only
#				# MIN >= MIN_VALUES & MAX >= MIN
#				Json.validate_dic_of_float(obj[prop], 0, INF, 0, prop)
#			TYPE_ARRAY:
#				# should have at least one value
#				# values of type number only, each >= MIN_VALUES
#				if obj[prop].length == 0:
#					obj[prop] = MIN_VALUES[prop]
#				for val in obj[prop]:
#					if typeof(val) != TYPE_REAL or val < MIN_VALUES[prop]:
#						val = MIN_VALUES[prop]
#			_:
#				print("Wrong type of %s in %s" % [prop, obj])
#				if mandatory:
#					obj[prop] = MIN_VALUES[prop]
#				else:
#					# remove property of the wrong type if not mandatory
#					obj.erase(prop)
#	elif mandatory:
#		print("No mandatory %s prop found in %s" % [prop, obj])
#		obj[prop] = MIN_VALUES[prop]


