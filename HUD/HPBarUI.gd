extends Control

const MOB_SHIFT_POS_Y := -80
const MOB_SIZE := Vector2(100, 5)

const AVATAR_SIZE_MULT := Vector2(0.3, 0.01)
const AVATAR_POS_MULT := Vector2(0.5, 0.05)


# set size and place
func activate(is_mob: bool, parent_position := Vector2(0, 0)) -> void:
	if is_mob:
		$ProgressBar.set_size(MOB_SIZE)
#		set_position(Vector2(MOB_SIZE.x / 2, MOB_SIZE.y / 2))
		set_global_position(parent_position \
		+ Vector2(-MOB_SIZE.x / 2, MOB_SHIFT_POS_Y))
	else:
		var w: Vector2 = OS.get_window_size()
		var x_size := w.x * AVATAR_SIZE_MULT.x
		$ProgressBar.set_size(Vector2(x_size, w.y * AVATAR_SIZE_MULT.y))
		set_global_position(Vector2(w.x * AVATAR_POS_MULT.x - x_size / 2, \
		w.y * AVATAR_POS_MULT.y))
	show()


func update_value(value_percent: float) -> void:
	$ProgressBar.set_value(value_percent)
	

