extends Node2D

var scroll_speed: float

var is_stop := false


func _ready():
	scroll_speed = 0.5 * Globals.world_speed
		
# warning-ignore:return_value_discarded
	Signals.connect("attack_start", self, "on_attack_start")
# warning-ignore:return_value_discarded
	Signals.connect("attack_finished", self, "on_attack_finished")


func on_attack_start():
	is_stop = true
	

func on_attack_finished():
	is_stop = false


func move():
	if not is_stop:
		self.position.x -= scroll_speed
	

