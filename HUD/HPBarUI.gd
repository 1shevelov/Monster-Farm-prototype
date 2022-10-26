extends Control

#var attacked_object: Node2D = null
#
#
#func _ready():
## warning-ignore:return_value_discarded
#	Signals.connect("being_attacked", self, "on_being_attacked")
## warning-ignore:return_value_discarded
#	Signals.connect("killed", self, "on_killed")
#
#
#func on_being_attacked(attacked_node: Node2D):
#	attacked_object = attacked_node
##	$ProgressBar.set_value($ProgressBar.get_max())
#	set_global_position(get_parent().get_global_position() - Vector2(0, 80))
#	attacked_object.get_node("HPBarUI").show()
##	print("Show attacked ", attacked_object)
##	print(get_global_rect())
#
#
#func update_health(health_pool_percent: float):
#	$ProgressBar.set_value(health_pool_percent)
##	$ProgressBar.modulate(Color.red)
#
#
#func on_killed(attacked_node: Node2D, _money_given: int = 0):
#	if attacked_node == attacked_object:
#		attacked_object.get_node("HPBarUI").hide()
#		attacked_object = null


const MOB_SHIFT_POS_Y := -80
const MOB_SIZE := Vector2(100, 5)

const AVATAR_SIZE_MULT := Vector2(0.3, 0.02)
const AVATAR_POS_MULT := Vector2(0.5, 0.1)


# set size and place
func activate(is_mob: bool, parent_position := Vector2(0, 0)) -> void:
	if is_mob:
		set_size(MOB_SIZE)
#		set_position(Vector2(MOB_SIZE.x / 2, MOB_SIZE.y / 2))
		set_global_position(parent_position \
		+ Vector2(-MOB_SIZE.x / 2, MOB_SHIFT_POS_Y))
	else:
		var w: Vector2 = OS.get_window_size()
		set_size(Vector2(w.x * AVATAR_SIZE_MULT.x, w.y * AVATAR_SIZE_MULT.y))
		set_global_position(Vector2(w.x * AVATAR_POS_MULT.x, \
		w.y * AVATAR_POS_MULT.y))
	show()


func update_value(value_percent: float) -> void:
	$ProgressBar.set_value(value_percent)
	

