extends Node2D


func _ready():
	$Spawner.set_objects($ImportWorld.load_all_objects())
	$Avatar.init_object($ImportWorld.load_avatar())
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 0)
	randomize()
	
	
func on_ready_to_start() -> void:
#	Globals.world_speed = Globals.RUN_WORLD_SPEED
	pass
