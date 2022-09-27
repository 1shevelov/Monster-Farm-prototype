extends ParallaxBackground

onready var sky_back := $SkyParallaxLayer
onready var mid_back := $MidgroundParallaxLayer

const MIDBACK_DELTA_SPEED := -25
const MIDBACK_DELTA_ATTACK_SPEED := 0
const SKY_DELTA_SPEED := 4

var is_attack := false


func _ready() -> void:
# warning-ignore:return_value_discarded
	Signals.connect("attack_start", self, "on_attack_status_change")
# warning-ignore:return_value_discarded
	Signals.connect("attack_finished", self, "on_attack_status_change")


func _process(delta) -> void:
	if not is_attack:
		mid_back.motion_offset.x += MIDBACK_DELTA_SPEED * delta
	else:
		mid_back.motion_offset.x += MIDBACK_DELTA_ATTACK_SPEED * delta
	sky_back.motion_offset.x += SKY_DELTA_SPEED * delta


func on_attack_status_change() -> void:
	is_attack = not is_attack


