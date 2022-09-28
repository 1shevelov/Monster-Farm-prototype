extends Control


func _ready():
# warning-ignore:return_value_discarded
	Signals.connect("game_over", self, "on_game_over")


func _on_RestartButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()


func on_game_over():
	self.show()


