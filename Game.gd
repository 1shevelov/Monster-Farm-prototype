extends Node2D

const Objects: GDScript = preload("res://objects/InitObjects.gd")
onready var objects_instance := Objects.new()


func _ready():
	objects_instance.load_all_objects()
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 0)
	randomize()
	
	
func on_ready_to_start() -> void:
#	Globals.world_speed = Globals.DEFAULT_WORLD_SPEED
	pass
