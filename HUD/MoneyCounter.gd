extends Control


func _ready():
# warning-ignore:return_value_discarded
	Signals.connect("update_money", self, "on_update_money")
	$CounterRTL.text = String(Globals.INITIAL_MONEY)


func on_update_money(new_sum: int):
	$CounterRTL.text = String(new_sum)
