extends Control

var attacked_object: Node2D = null


func _ready():
# warning-ignore:return_value_discarded
	Signals.connect("being_attacked", self, "on_being_attacked")
# warning-ignore:return_value_discarded
	Signals.connect("health_changed", self, "on_health_changed")
# warning-ignore:return_value_discarded
	Signals.connect("killed", self, "on_killed")


func on_being_attacked(attacked_node: Node2D):
	attacked_object = attacked_node
	$ProgressBar.set_value($ProgressBar.get_max())
	show()
	print("Show attacked ", attacked_object)


func on_health_changed(attacked_node: Node2D, health_pool_percent: float):
	if attacked_node == attacked_object:
		$ProgressBar.set_value(health_pool_percent)


func on_killed(attacked_node: Node2D):
	if attacked_node == attacked_object:
		hide()
		attacked_object = null
