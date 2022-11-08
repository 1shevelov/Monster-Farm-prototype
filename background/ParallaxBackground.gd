extends ParallaxBackground

onready var sky_back := $SkyParallaxLayer
onready var mid_back := $MidgroundParallaxLayer

const MIDBACK_DELTA_SPEED := -5
const MIDBACK_DELTA_STOP_SPEED := 0
const SKY_DELTA_SPEED := 4

var is_world_moving := false


func _ready() -> void:
# warning-ignore:return_value_discarded
	Signals.connect("world_stopped", self, "on_world_move_change")
# warning-ignore:return_value_discarded
	Signals.connect("attack_finished", self, "on_world_move_change")


func _process(delta) -> void:
	if is_world_moving:
		mid_back.motion_offset.x += MIDBACK_DELTA_SPEED * Globals.RUN_WORLD_SPEED * delta
#	else:
#		mid_back.motion_offset.x += MIDBACK_DELTA_STOP_SPEED * delta
	sky_back.motion_offset.x += SKY_DELTA_SPEED * delta


func on_world_move_change() -> void:
	is_world_moving = not is_world_moving


