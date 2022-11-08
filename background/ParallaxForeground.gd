extends ParallaxBackground

onready var foreground := $ForegroundParallaxLayer

const FOREGROUND_DELTA_SPEED := -20
const FOREGROUND_DELTA_STOP_SPEED := 0

var is_world_moving := false


func _ready() -> void:
# warning-ignore:return_value_discarded
	Signals.connect("world_stopped", self, "on_world_move_change")
# warning-ignore:return_value_discarded
	Signals.connect("attack_finished", self, "on_world_move_change")


func _process(delta) -> void:
	if is_world_moving:
		foreground.motion_offset.x += FOREGROUND_DELTA_SPEED * Globals.RUN_WORLD_SPEED * delta
#	else:
#		foreground.motion_offset.x += FOREGROUND_DELTA_STOP_SPEED * delta


func on_world_move_change() -> void:
	is_world_moving = not is_world_moving


