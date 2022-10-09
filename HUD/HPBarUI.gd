extends Control

var attacked_object: Node2D = null


func _ready():
# warning-ignore:return_value_discarded
	Signals.connect("being_attacked", self, "on_being_attacked")
# warning-ignore:return_value_discarded
	Signals.connect("killed", self, "on_killed")


func on_being_attacked(attacked_node: Node2D):
	attacked_object = attacked_node
#	$ProgressBar.set_value($ProgressBar.get_max())
	set_global_position(get_parent().get_global_position() - Vector2(0, 80))
	attacked_object.get_node("HPBarUI").show()
#	print("Show attacked ", attacked_object)
#	print(get_global_rect())


func update_health(health_pool_percent: float):
	$ProgressBar.set_value(health_pool_percent)
#	$ProgressBar.modulate(Color.red)


func on_killed(attacked_node: Node2D, _money_given: int = 0):
	if attacked_node == attacked_object:
		attacked_object.get_node("HPBarUI").hide()
		attacked_object = null
