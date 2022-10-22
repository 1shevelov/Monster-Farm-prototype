extends Node2D

const IMPORT_OBJECTS: GDScript = preload("res://objects/ImportObjects.gd")
onready var import_objects_instance := IMPORT_OBJECTS.new()


func _ready():
	import_objects_instance.load_all_objects()
	$Avatar.init(import_objects_instance.get_avatar())
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 0)
	randomize()
	
	
func on_ready_to_start() -> void:
#	Globals.world_speed = Globals.RUN_WORLD_SPEED
	pass
