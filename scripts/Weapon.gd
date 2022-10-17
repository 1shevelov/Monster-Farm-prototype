extends Reference
class_name Weapon

var name: String = ""
var damage_min: int = 0
var damage_max: int = 0
var delay: float = 0.0 # in seconds
var one_time: bool = false
var description: String = ""
var probability: float = 1.0
#var damage_type
#var image_res_file: String = "res://"

func init(obj: Dictionary) -> bool:
	
	if obj.has("name") and typeof(obj.name) == TYPE_STRING:
		name = obj.name
	
	if obj.has("damage"):
		if typeof(obj.damage) == TYPE_REAL:
			damage_min = int(obj.damage)
			damage_max = damage_min
		elif typeof(obj.damage) == TYPE_DICTIONARY:
			if obj.damage.has("min") and typeof(obj.damage.min) == TYPE_REAL:
				damage_min = int(obj.damage.min)
			if obj.damage.has("max") and typeof(obj.damage.max) == TYPE_REAL:
				damage_max = int(obj.damage.max)
		if damage_min < 0:
			damage_min = 0
		if damage_max < damage_min:
			damage_max = damage_min
	
	return true
