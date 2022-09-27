extends ParallaxBackground

onready var foreground := $ForegroundParallaxLayer

const FOREGROUND_DELTA_SPEED := -100
const FOREGROUND_DELTA_ATTACK_SPEED := 0

var is_attack := false


func _ready() -> void:
# warning-ignore:return_value_discarded
	Signals.connect("attack_start", self, "on_attack_status_change")
# warning-ignore:return_value_discarded
	Signals.connect("attack_finished", self, "on_attack_status_change")


func _process(delta) -> void:
	if not is_attack:
		foreground.motion_offset.x += FOREGROUND_DELTA_SPEED * delta
	else:
		foreground.motion_offset.x += FOREGROUND_DELTA_ATTACK_SPEED * delta


func on_attack_status_change() -> void:
	is_attack = not is_attack


